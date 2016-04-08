Dripper.config model: :users do
  dripper mailer: :user_mailer do
    dripper action: :welcome
    dripper action: :newsletter, wait: 1.minutes, scope: -> {has_username}
  end
end
