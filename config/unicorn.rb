worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
if ENV['RACK_ENV'] == 'development'
	timeout 180
else
	timeout 30
end
preload_app true
before_fork do |server, worker|
	Signal.trap 'TERM' do
		puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
		Process.kill 'QUIT', Process.pid
	end
	if defined?(Resque)
		Resque.redis.quit
	end
end
after_fork do |server, worker|
	Signal.trap 'TERM' do
		puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
	end
	if defined?(Resque)
		Resque.redis = ENV['REDISTOGO_URL']
	end
end