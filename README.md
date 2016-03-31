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

### Transactional Message
This will send a new email on every chat
```
dripper :chat_message do
  message :chat_mailer, :new_chat
end
```

### Weekly Digest message
In this case, if we want to send a weekly digest, we should have a weekly digest AR model that gets populated by a rake task.

```
dripper :weekly_digest do
  message :digest_mailer, :weekly_digest 
end
```

## Details

* We will only send one message per this key [:id, :mailer, :action]
* Use scopes to control who if a message gets sent
* Create new models for transactional emails

This project rocks and uses MIT-LICENSE.
