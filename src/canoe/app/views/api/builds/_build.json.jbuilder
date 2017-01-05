json.extract! build, :artifact_url, :repo_url, :build_id, :url, :branch, :build_number, :sha, :created_at
json.passed_ci build.passed_ci?
json.compliant build.compliant?
