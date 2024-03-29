
namespace :db do
  namespace :seed do
    Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each do |filename|
      task = File.basename(filename, '.rb').intern
      task task => :environment do
        load(filename) if File.exist?(filename)
      end
    end
  end
end
