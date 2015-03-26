# Run Deploy recipe
include_recipe "node_app::deploy"

# Run Configure recipe
include_recipe "node_app::configure"

# Remove old builds
include_recipe "node_app::delete_old_builds"
