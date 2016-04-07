# Dripper

Clean up your mailer code with a rules-based drip campaign system that works natively with rails

## Status
This project only exists in my mind, but I wanted to write out how I think it should work.

## Benefits:
 * Remove mailer code from your controllers
 * Rely on active record scopes 
 * Build complex DRIP campaigns in a DRY fashion


## Key insight:

To clean up your messaging code, each message should have a corresponding record in a model.  So, instead of trying to navigate through your user to an order, chat, message, or whatever, you just put the rules on the chat, order and message.


## Simple Stuff
``` config/initializers/dripper.rb
  Dripper.config model: :users do
    # send a welcome message when a user is created
    dripper mailer: :welcome_mailer, action: :welcome
  end

  dripper :orders do
    # send a successful order message
    dripper mailer: :order_mailer, action: :new_order, scope: -> { paid }
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
  dripper mailer: :user_mailer, actio: :confirmation, scope: -> { unconfirmed }
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
```
# runs all open drippers
rake dripper:run
```

## Run immediately
Sometimes you want to evaluate immediately instead of waiting for a rake task.

This method will hook into ActiveRecord post_commit hooks and queries on a per-record basis (for create / update)

Use this method sparingly, as it will create lots of run-time load.

```
class User
  acts_as_dripper 
end
```

You can also just set it for specific methods
```
class User
  acts_as_dripper only: [:change_password]
end
```

or exclude just one
```
class User
  acts_as_dripper except: [:expensive_query]
end
```


## Details

* We will only send one message per this key [:id, :mailer, :action]
* Use scopes to control if a message gets sent
* Create new models for transactional emails


This project rocks and uses MIT-LICENSE.
