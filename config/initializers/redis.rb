r = Redis.new
Resque.redis = r
Resque.redis.namespace = "printatcu-alt:resque"
Resque.inline = Rails.env.development?
Resque.schedule = YAML.load_file(Rails.root.join("config/schedule.yml"))
$redis = Redis::Namespace.new("printatcu-alt", :redis => r)