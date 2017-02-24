# Dripper
[![Build Status](https://travis-ci.org/tarr11/dripper.svg?branch=master)](https://travis-ci.org/tarr11/dripper)

DRY up your mailer code with a rules-based drip campaign system that works natively with rails and ActionMailer.

## Benefits:
 * Remove mailer state logic from your controllers
 * Rely on active record scopes 
 * Build sophisticated DRIP campaigns in a DRY fashion

## Why:
I needed a DRIP email service, and as both developer and marketer, I wanted to build something that works easily with rails.  Most DRIP SAAS products are too expensive for websites where visitors don't pay.  I love sites like intercom, but they don't make sense unless are generating revenue.  

## Philosophy
Clean up your email messaging code by creating a rails model for each message. So, instead of trying to navigate through your user to an order, chat, message, or whatever, you just put the rules on the chat, order and message.  

## Get Started

### Step 1: Add to your gemfile and then `bundle install`
```
gem 'dripper_mail'
```

### Step 2: Install Migrations
```
rake dripper:install:migrations
rake db:migrate
```

### Step 3: Add a simple configuration file
``` config/initializers/dripper.rb
  Dripper.config model: :users do
    # send a welcome message when a user is created
    dripper mailer: :welcome_mailer, action: :welcome
  end
```

### Step 4: Include dripper in your models so emails get sent automatically
```
class Newsletter < ActiveRecord::Base
  include Dripper::Drippable
  belongs_to :user
end
```

This example expects you to have a mailer method that looks like this:
```
class UserMailer < ApplicationMailer
  def newsletter(newsletter)
    mail to: "to@example.org"
  end
end
```

### Step 5: Go! 
Simply create a new model and insert it into your database.  your Mail code will get called automatically. 
```
rails c
Newsletter.create(user: User.first, subject: "Hello!")
```


## Use Scopes to limit who this gets sent to
``` config/initializers/dripper.rb

  dripper model: :orders do
    # send a successful order message
    dripper mailer: :order_mailer, action: :new_order, scope: -> { paid }
  end
```

## Use wait or wait_until to delay messages (see deliver_later on activemailer for details on wait/wait_until syntax)
Use a proc for wait_until so that it gets evaluated at the correct time.
```
 dripper model: :users do
    dripper mailer: :welcome_mailer, action: :welcome, scope: -> { new_user }, wait_until: -> {  Date.tomorrow.noon }
    dripper mailer: :welcome_mailer, action: :welcome, scope: -> { new_user }, wait: -> {  1.hours }
 end
```

## Marketing / DRIP Stuff
Drip messages are designed to get people to take specific actions based on their lifecycle

### Step 1/2/3
In this case, we want to sent 3 messages, on day 1,3 and 7.  We only want to send the last message if they haven't subscribed.  

Note that we can nest options (mailer, scope, model, etc) which makes the code cleaner

```
class User
  scope :day_count, ->(day_count) {where("created_at < ?", DateTime.now - day_count.days) }
  scope :no_customer, -> {where.not(:id => Subscription.select(:user_id).uniq) }
  scope :customer, -> {joins(:subscriptions).where("subscriptions.is_active = true") }
end

dripper model: :users, scope: -> { confirmed } do
  dripper mailer: :onboarding do
    dripper action: :day1, scope: -> { day_count(1)  }
    dripper action: :day3, scope: -> { day_count(3) } 
    dripper action: :day7_no_customer,  scope: -> { day_count(7).merge(-> { no_customer } ) } 
    dripper action: :day7_customer,  scope: -> { day_count(7).merge(-> { customer } ) } 
  end
end
```

### User Confirmation
This could potentially replace devise's awful mess :)
```
dripper model: :users do
  dripper mailer: :user_mailer, action: :confirmation, scope: -> { unconfirmed }
end
```

### Change Password
This will send a password changed email if the password has been changed in the last 30 minutes
```
dripper model: :users do
  dripper mailer: :user_mailer, action: :change_password, scope: -> { password_changed(30.minutes.ago) }
end
```

### Inactive User
```
# define inactive scope
class User 
  scope :inactive, -> { where("last_session_at < ?", DateTime.today - 1.months) }
end

# dripper code uses scope
dripper model: :users do
  dripper mailer: :user_mailer, action: :inactive, scope: :inactive, -> { inactive }
end
```

Notice in this case, we will only send 1 inactive message, ever.  Also this one would require a rake task , as the user would not be triggering it (since they are inactive)  Alternatively you could have a rake task that sets inactive_at.

If you want to send more than one, you should create a new model that corresponds to the mailer.  Run a rake task that populates this model.  

This may sounds like a pain, but things will be cleaner and you will be able to control what gets sent when.   You'll also get the benefit of seeing your inactive users in a nice queryable format.

Here's how that would look:

### Inactive User every few months
```
class InactiveUser
  # user_id, :integer
  # inactive_at :datetime
  
   belongs_to :user
end

dripper :inactive_users do
  dripper :inactive_mailer, -> {:inactive}
end
```

### Transactional Message
This will send a new email on every chat
```
dripper :chat_message do
  dripper :chat_mailer, :new_chat
end
```

### Weekly Digest message
Similarly, in this case, if we want to send a weekly digest, we should have a weekly digest AR model that gets populated by a rake task.

```
class WeeklyDigest
  belongs_to :user
  # week_start_on, week_end_on
  # other stuff
  
  def self.create_weekly_digest(start_on)
    User.all.each do |u|
      u.weekly_digests.create week_start_on: start_on, week_end_on: start_on + 1.weeks
    end
  end
end

dripper model: :weekly_digest do
  dripper mailer: :digest_mailer, action: :weekly_digest 
end
```

## Rake Task 
NOTE: this doesn't work yet...

```
# runs all open drippers
rake dripper:run
```



## Details

* We will only send one message per this key [:id, :mailer, :action]
* By default, we will only send to NEW records (so that you don't spam your entire list on your first deploy)
* Use scopes to control if a message gets sent
* Create new models for transactional emails


This project rocks and uses MIT-LICENSE.
