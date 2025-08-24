# dLogin by n1llsqq
# OpenSource project for Denizen CIS Community (https://discord.gg/ERPf9rwA)
# Made with 💘

consoleNarrate:
  type: world
  events:
    after server start:
    - flag <server.players> dLoginData.authorized:false
    - narrate '<&6>[dLogin] <&7>Скрипт был запущен. Made by <&6>n1llsqq'
    - if <util.has_file[dLogin.yml].not>:
      - yaml create id:dLogin
      - ~yaml savefile:dLogin.yml id:dLogin
      - narrate '<&6>[dLogin] <&7>YAML-file was succesfully created'
    - ~yaml load:dLogin.yml id:dLogin

registerCmd:
  type: command
  name: register
  description: Registration
  usage: /register
  aliases:
    - reg
    - r
  tab completions:
    1: [password]
    2: [confirm password]
  script:
  - define pass <context.args.get[1]>
  - define passConfirm <context.args.get[2]>
  - define config <script[dLoginConfig].data_key[settings]>
  - if <player.has_flag[dLoginData]>:
    - narrate '<&c>You<&sq>ve already registered!'
    - stop
  - if <[pass]||null> == null:
    - narrate '<&c>Enter password!'
    - stop
  - if <[pass].length.is_less_than[<[config].get[passMinLength]>]>:
    - narrate '<&c>Password is too short!'
    - stop
  - if <[pass].length.is_more_than[<[config].get[passMaxLength]>]>:
    - narrate '<&c>Password is too long!'
    - stop
  - if <script[passwordsblacklist].data_key[passwords].contains[<[pass]>]>:
    - narrate '<&c>Password is too easy!'
    - stop
  - if <[passConfirm]||null> == null:
    - narrate '<&c>Confirm password!'
    - stop
  - if <[passConfirm]> != <[pass]> || <[pass]> != <[passConfirm]>:
    - narrate '<&c>Passwords don<&sq>t matches!'
    - stop
  - ~yaml id:dLogin set passwords.<element[<player.flag[hashSalt]><player.name>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><player.name>].to_hex>:<element[<player.flag[hashSalt]><[pass]>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><[pass]>].to_hex>
  - ~yaml savefile:dLogin.yml id:dLogin
  - flag <player> dLoginData:<map[loginAttempts=<[config].get[loginAttempts]>;ip=<player.ip>;authorized=true;license=false]>
  - flag <player> authorization:!
  - narrate '<&a>You have successfully registered'
  - playsound <player> sound:entity.player.levelup pitch:2

loginCmd:
  type: command
  name: login
  description: Login
  usage: /login
  aliases:
    - log
    - l
  tab completions:
    1: [password]
  script:
  - define pass <element[<player.flag[hashSalt]><context.args.get[1]>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><context.args.get[1]>].to_hex>
  - define config <script[dLoginConfig].data_key[settings]>
  - if <player.flag[dLoginData].get[authorized].equals[true]>:
    - narrate '<&c>You<&sq>ve already authorized!'
    - stop
  - if <[pass]> != <yaml[dLogin].read[passwords].get[<element[<player.flag[hashSalt]><player.name>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><player.name>].to_hex>]>:
    - if <player.flag[dLoginData].get[loginAttempts].equals[1].not>:
      - flag <player> dLoginData.loginAttempts:--
      - narrate '<&c>Wrong password! <proc[suffixreplace]>'
      - stop
    - else:
      - flag <player> dLoginData.loginAttempts:<[config].get[loginAttempts]>
      - ban <player> 'reason:Подозрительная активность. Вы заблокированы на 15 минут' expire:15m
      - stop
  - flag <player> dLoginData:<map[loginAttempts=<[config].get[loginAttempts]>;ip=<player.ip>;authorized=true;license=false]>
  - flag <player> authorization:!
  - if <player.flag[dLoginData].get[license].is_truthy.not>:
    - flag <player> activeSession expire:<[config].get[sessionDuration]>
  - narrate '<&a>You have successfully authorized'
  - playsound <player> sound:entity.player.levelup pitch:2

changepasswordCmd:
  type: command
  name: changepassword
  description: Change password
  usage: /changepassword
  aliases:
    - changepass
  tab completions:
    1: [current password]
    2: [new password]
  script:
  - define passRaw <context.args.get[1]>
  - define passNew <context.args.get[2]>
  - define pass <element[<player.flag[hashSalt]><context.args.get[1]>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><context.args.get[1]>].to_hex>
  - define config <script[dLoginConfig].data_key[settings]>
  - if <[passRaw]||null> == null:
    - narrate '<&c>Confirm password!'
    - stop
  - if <[pass]> != <yaml[dLogin].read[passwords].get[<element[<player.flag[hashSalt]><player.name>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><player.name>].to_hex>]>:
    - narrate '<&c>Wrong password!'
    - stop
  - if <[passNew].length.is_less_than[<[config].get[passMinLength]>]>:
    - narrate '<&c>Password is too short!'
    - stop
  - if <[passNew].length.is_more_than[<[config].get[passMaxLength]>]>:
    - narrate '<&c>Password is too long!'
    - stop
  - if <script[passwordsblacklist].data_key[passwords].contains[<[passNew]>]>:
    - narrate '<&c>Password is too easy!'
    - stop
  - if <[passNew]||null> == null:
    - narrate '<&c>Enter new password!'
    - stop
  - if <[passNew]> == <[passRaw]>:
    - narrate '<&c>Passwords matches!'
    - stop
  - ~yaml id:dLogin set passwords.<element[<player.flag[hashSalt]><player.name>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><player.name>].to_hex>:<element[<player.flag[hashSalt]><[passNew]>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><[passNew]>].to_hex>
  - ~yaml savefile:dLogin.yml id:dLogin
  - narrate '<&a>Password has succesfully changed'
  - playsound <player> sound:entity.player.levelup pitch:2

loginHandler:
  debug: false
  type: world
  events:
   on player join:
   - define config <script[dLoginConfig].data_key[settings]>
   # Active Session
   - if <[config].get[sessions].is_truthy> && <player.has_flag[activeSession]>:
     - if <player.has_flag[dLoginData]> && <player.flag[dLoginData].get[ip].equals[<player.ip>]>:
       - flag <player> dLoginData.authorized:true
       - narrate '<&a>Session is active. You are automatically logged in'
       - playsound <player> sound:entity.player.levelup pitch:2
       - stop
   # Authorization
   - if <player.has_flag[dLoginData]> && <player.has_flag[dLoginData].get[ip]>:
     - narrate '<&7>Log in: <&6>/login [пароль]'
     - flag <player> authorization expire:<[config].get[authorizationDuration]>
     - while <player.has_flag[authorization]>:
       - actionbar '<&7><&6><player.flag_expiration[authorization].add[1t].duration_since[<util.time_now>].formatted.replace_text[s].with[<&sp>sec].replace_text[m].with[<&sp>min]> <&7>left to log in'
       - wait 1s
     - if <player.flag[dLoginData].get[authorized].equals[false]>:
       - kick <player> 'reason:Authorization time has expired'
   # Registration
   - else:
     - narrate '<&7>Register: <&6>/reg [password] [confirm password]'
     - flag <player> authorization expire:<[config].get[authorizationDuration]>
     - while <player.has_flag[authorization]>:
       - actionbar '<&7><&6><player.flag_expiration[authorization].add[1t].duration_since[<util.time_now>].formatted.replace_text[s].with[<&sp>sec].replace_text[m].with[<&sp>min]> <&7>left to register'
       - wait 1s
     - if <player.has_flag[dLoginData].not>:
       - kick <player> 'reason:Registration time has expired'
   on player quit:
   - if <player.has_flag[dLoginData]>:
     - flag <player> dLoginData.authorized:false
   on player joins:
   - if <player.has_flag[hashSalt].not>:
     - flag <player> hashSalt:<element[1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ?&!*].to_list.random[24].separated_by[]>
   on player steps on block flagged:authorization:
   - determine cancelled
   on player breaks block flagged:authorization:
   - determine cancelled
   on player changes gamemode flagged:authorization:
   - determine cancelled
   on player crafts item flagged:authorization:
   - determine cancelled
   on player consumes item flagged:authorization:
   - determine cancelled
   on player damages entity flagged:authorization:
   - determine cancelled
   on player damaged flagged:authorization:
   - determine cancelled
   on player drags in inventory flagged:authorization:
   - determine cancelled
   on player edits book flagged:authorization:
   - determine cancelled
   on player clicks block flagged:authorization:
   - determine cancelled
   on player clicks entity flagged:authorization:
   - determine cancelled
   on player swaps items flagged:authorization:
   - determine cancelled
   on command flagged:authorization:
   - if <context.command> !matches <list[l|log|login|r|reg|register]>:
     - narrate '<&c>Access denied'
     - determine cancelled

# Suffix Replacer
suffixreplace:
  type: procedure
  debug: false
  definitions: number
  script:
  - define number <player.flag[dLoginData].get[loginAttempts]>
  - if <[number].ends_with[1]>:
    - define suffix <&c><[number]><&sp>attempt<&sp>left
  - else:
    - define suffix <&c><[number]><&sp>attempts<&sp>left
  - determine <[suffix]>

# Config
dLoginConfig:
  type: data
  debug: false
  settings:
    passMinLength: 6
    passMaxLength: 24
    loginAttempts: 5
    authorizationDuration: 30s
    sessions: true
    sessionDuration: 10m

# Easy passwords list
passwordsBlacklist:
  type: data
  debug: false
  passwords:
  - qwerty
  - n1llsqq