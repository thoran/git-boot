# git-boot/CHANGELOG.md

## [0.9.0] - 2025-07-02
### Introduce encrypted token storage as the preferred method of storing access tokens, while maintaining backward compatibility with unencrypted access tokens.
1. + require 'ApiCredentials', to allow encrypted token storage.
2. /:note, :token\_note, :access\_token\_note/:name, :token\_name, :access\_token\_name/
3. + config\_filename(): returns the path to GitHub config file.
4. + configured\_access\_token\_name(): reads and evaluates config file to get ACCESS\_TOKEN\_NAME.
5. + access\_token\_name(): determine which token name to use.
6. + encrypted\_access\_token(): retrieve encrypted token using ApiCredentials.
7. /supplied\_stored\_access\_token\_filename()/supplied\_unencrypted\_access\_token\_filename()/
8. /default\_stored\_access\_token\_filename()/default\_unencrypted\_access\_token\_filename()/
9. /stored\_access\_token\_filename()/unencrypted\_access\_token\_filename()/
10. /stored\_access\_token()/unencrypted\_access\_token()/
11. ~ access\_token(): updated priority order to prefer encrypted tokens over unencrypted, but still after a supplied access token.
