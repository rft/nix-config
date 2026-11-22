# The `homelab` Hermes plugin (tools for this repo's self-hosted services), as
# the plugin directory that services.hermes-agent.extraPlugins links into
# $HERMES_HOME/plugins. Its only imports beyond the stdlib are httpx and
# Hermes' own agent.secret_scope, both already in the Hermes venv.
{ runCommandLocal }:
runCommandLocal "homelab" { } ''
  cp -r ${./plugin} $out
''
