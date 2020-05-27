# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"  
require "sinatra/cookies"                                                             #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

events_table = DB.from(:events)
rsvps_table = DB.from(:rsvps)
# users_table = DB.from(:users)

# Home page (all events)
get "/" do
    @events = events_table.all
    view "events"
end

# Show a single event
get "/events/:id" do
    # SELECT * FROM events WHERE id=:id
    @event = events_table.where(:id => params["id"]).to_a[0]
    # SELECT * FROM rsvps WHERE event_id=:id
    @rsvps = rsvps_table.where(:event_id => params["id"]).to_a
    # SELECT COUNT(*) FROM rsvps WHERE event_id=:id AND going=1
    @count = rsvps_table.where(:event_id => params["id"], :going => true).count
    view "event"
end

# Form to create a new RSVP
get "/events/:id/rsvps/new" do
    @event = events_table.where(:id => params["id"]).to_a[0]
    view "new_rsvp"
end

# Receiving end of new RSVP form
get "/events/:id/rsvps/create" do
    rsvps_table.insert(:event_id => params["id"],
                       :going => params["going"],
                       :name => params["name"],
                       :email => params["email"],
                       :comments => params["comments"])
    @event = events_table.where(:id => params["id"]).to_a[0]
    view "create_rsvp"
end

# Form to create a new user
get "/users/new" do
    view "new_user"
end

# Receiving end of new user form
get "/users/create" do
    puts params
    view "create_user"
end

# Form to login
get "/logins/new" do
    view "new_login"
end

# Receiving end of login form
get "/logins/create" do
    puts params
    view "create_login"
end

# Logout
get "/logout" do
    view "logout"
end