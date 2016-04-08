# desc "Runs dripper for all configured jobs"
namespace :dripper do
  task :run => :environment do
    Dripper.execute
  end
end
