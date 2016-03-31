# Dripper

Clean up your mailer code with a rules-based drip campaign system that works natively with rails

Here's the key insight:

To clean up your messaging code, each message should have a corresponding record in a model.  So, instead of trying to navigate through your user to an order, chat, message, or whatever, you just put the rules on the chat, order and message.

## Config
```
  # config/initializers/dripper.rb
  dripper.config do
    email_model :users
    email_field :email
    throttle: 1.days # will not send a message to this user more than every 3 days
    start_at: "2016-03-01" # do not send any messages for models with a created_at date before this date
    dripper_queue :active_job # when acts_as_dripper is included, it will queue through active job
  end
```

## Simple Stuff
```
dripper :users do 
  # send a welcome message
  message :welcome_mailer, :welcome
end

dripper :orders do
  # send a successful order message
  message :order_mailer, :new_order, { paid }
end
```

## Drip Stuff
Drip messages are designed to get people to take specific actions based on their lifecycle

### Inactive User
```
# define inactive scope
class User 
  scope :inactive, -> { where("last_session_at < ?", DateTime.today - 1.months) }
end

# dripper code uses scope
dripper :users do
  message :user_mailer, :inactive, { inactive }
end
```

Notice in this case, we will only send 1 inactive message, ever.  If you want to send more than one, you should create a new model that corresponds to the mailer.  Run a rake task that populates this model.  

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
  message :inactive_mailer, :inactive
end
```

### Transactional Message
This will send a new email on every chat
```
dripper :chat_message do
  message :chat_mailer, :new_chat
end
```

### Weekly Digest message
Similarly, in this case, if we want to send a weekly digest, we should have a weekly digest AR model that gets populated by a rake task.

```
dripper :weekly_digest do
  message :digest_mailer, :weekly_digest 
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


## Details

* We will only send one message per this key [:id, :mailer, :action]
* Use scopes to control if a message gets sent
* Create new models for transactional emails


This project rocks and uses MIT-LICENSE.
