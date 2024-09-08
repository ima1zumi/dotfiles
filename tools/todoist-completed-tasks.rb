require 'net/http'
require 'json'
require 'time'

# Usage: op run --env-file=".env" -- ruby todoist-completed-tasks.rb 2024-09-06

token = ENV['TODOIST_API_TOKEN']
working_project_ids = ENV['TODOIST_WORKING_PROJECT_IDS'].split(',')
since = Time.parse(ARGV[0]).iso8601 if ARGV[0]

def get_completed_tasks(token, project_id = nil, since = nil)
  uri = URI("https://api.todoist.com/sync/v9/completed/get_all")

  params = {}
  params[:project_id] = project_id if project_id
  params[:since] = since if since
  uri.query = URI.encode_www_form(params)

  res = Net::HTTP.get_response(uri, 'Authorization' => "Bearer #{token}")
  JSON.parse(res.body)
end

working_project_ids.each do |project_id|
  json = get_completed_tasks(token, project_id, since)
  content = json['items'].map { _1['content'].gsub(/@.*/, '').strip }
  content.each { puts "- #{_1}" }
end
