# dLogin by n1llsqq
# OpenSource project for Denizen CIS Community (https://discord.gg/ERPf9rwA)
# Made with 💘

# Указание моего авторства в консоли. Пожалуйста, оставьте его)
consoleNarrate:
  type: world
  events:
    after server start:
    - narrate '<&6>[dLogin] <&7>Скрипт был запущен. Сделано <&6>n1llsqq'

registerCmd:
  type: command
  name: register
  description: Регистрация
  usage: /register
  aliases:
    - reg
    - r
  tab completions:
    1: [пароль]
    2: [повтор пароля]
  script:
  - define pass <context.args.get[1]>
  - define passConfirm <context.args.get[2]>
  - define config <script[dLoginConfig].data_key[settings]>
  - if <player.has_flag[dLoginData]>:
    - narrate '<&c>Вы уже зарегистрированы!'
    - stop
  - if <[pass]||null> == null:
    - narrate '<&c>Введите пароль!'
    - stop
  - if <[pass].length.is_less_than[<[config].get[passMinLength]>]>:
    - narrate '<&c>Слишком короткий пароль!'
    - stop
  - if <[pass].length.is_more_than[<[config].get[passMaxLength]>]>:
    - narrate '<&c>Слишком длинный пароль!'
    - stop
  - if <script[passwordsblacklist].data_key[passwords].contains[<[pass]>]>:
    - narrate '<&c>Слишком лёгкий пароль!'
    - stop
  - if <[passConfirm]||null> == null:
    - narrate '<&c>Подтвердите пароль!'
    - stop
  - if <[passConfirm]> != <[pass]> || <[pass]> != <[passConfirm]>:
    - narrate '<&c>Пароли не совпадают!'
    - stop
  - flag <player> dLoginData:<map[pass=<element[<player.flag[hashSalt]><[pass]>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><[pass]>].to_hex>;loginAttempts=<[config].get[loginAttempts]>;ip=<player.ip>;authorized=true]>
  - flag <player> authorization:!
  - narrate '<&a>Вы успешно зарегистрировались'
  - playsound <player> sound:entity.player.levelup pitch:2

loginCmd:
  type: command
  name: login
  description: Вход в аккаунт
  usage: /login
  aliases:
    - log
    - l
  tab completions:
    1: [пароль]
  script:
  - define pass <element[<player.flag[hashSalt]><context.args.get[1]>].utf8_encode.hmac[type=HmacSHA256;key=<player.flag[hashSalt]><context.args.get[1]>].to_hex>
  - define config <script[dLoginConfig].data_key[settings]>
  - if <player.has_flag[dLoginData].not>:
    - narrate '<&c>Сначала зарегистрируйтесь с помощью /reg [пароль] [повтор пароля]'
    - stop
  - if <player.flag[dLoginData].get[authorized].equals[true]>:
    - narrate '<&c>Вы уже авторизованы!'
    - stop
  - if <[pass]> != <player.flag[dLoginData].get[pass]>:
    - if <player.flag[dLoginData].get[loginAttempts].equals[1].not>:
      - flag <player> dLoginData.loginAttempts:--
      - narrate '<&c>Пароли не совпадают! <proc[russificator]>'
      - stop
    - else:
      - flag <player> dLoginData.loginAttempts:<[config].get[loginAttempts]>
      - ban <player> 'reason:Подозрительная активность. Вы заблокированы на 15 минут' expire:15m
      - stop
  - flag <player> dLoginData:<map[pass=<player.flag[hashSalt]><[pass]>;loginAttempts=<[config].get[loginAttempts]>;ip=<player.ip>;authorized=true]>
  - flag <player> authorization:!
  - flag <player> activeSession expire:<[config].get[sessionTime]>
  - narrate '<&a>Вы успешно вошли в аккаунт'
  - playsound <player> sound:entity.player.levelup pitch:2

loginHandler:
  debug: false
  type: world
  events:
   on player join:
   # Активная сессия
   - if <script[dLoginConfig].data_key[settings].get[sessions].is_truthy>:
     - if <player.has_flag[dLoginData]> && <player.flag[dLoginData].get[ip].equals[<player.ip>]>:
       - flag <player> dLoginData.authorized:true
       - narrate '<&a>Сессия активна. Вы автоматически вошли в аккаунт'
       - playsound <player> sound:entity.player.levelup pitch:2
       - stop
   # Авторизация
   - if <player.has_flag[dLoginData]>:
     - narrate '<&7>Авторизуйтесь: <&6>/login [пароль]'
     - flag <player> authorization expire:<script[dLoginConfig].data_key[settings].get[authorizationTime]>
     - while <player.has_flag[authorization]>:
       - actionbar '<&7>У Вас осталось <&6><player.flag_expiration[authorization].add[1t].duration_since[<util.time_now>].formatted.replace_text[s].with[<&sp>сек]> <&7>на вход'
       - wait 1s
     - if <player.flag[dLoginData].get[authorized].equals[false]>:
       - kick <player> 'reason:Время авторизации истекло'
   # Регистрация
   - else:
     - narrate '<&7>Зарегистрируйтесь: <&6>/reg [пароль] [повтор пароля]'
     - flag <player> authorization expire:<script[dLoginConfig].data_key[settings].get[authorizationTime]>
     - while <player.has_flag[authorization]>:
       - actionbar '<&7>У Вас осталось <&6><player.flag_expiration[authorization].add[1t].duration_since[<util.time_now>].formatted.replace_text[s].with[<&sp>сек]> <&7>на регистрацию'
       - wait 1s
     - if <player.has_flag[dLoginData].not>:
       - kick <player> 'reason:Время регистрации истекло'
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
   on player swaps items flagged:authorization:
   - determine cancelled

# Конфиг
dLoginConfig:
  type: data
  debug: false
  settings:
    # Минимальная длина пароля
    passMinLength: 6
    # Максимальная длина пароля
    passMaxLength: 24
    # Максимальное количество попыток для входа
    loginAttempts: 5
    # Максимальное время входа/регистрации
    authorizationTime: 30s
    # Сессии (true - включено)
    sessions: false
    # Длительность сессии
    sessionTime: 10m

# Список лёгких паролей
passwordsBlacklist:
  type: data
  debug: false
  passwords:
  - qwerty
  - n1llsqq

# Подмена окончаний
russificator:
  type: procedure
  debug: false
  definitions: number
  script:
  - define number <player.flag[dLoginData].get[loginAttempts]>
  - if <[number].ends_with[1]>:
    - define suffix <&c>Осталась<&sp><[number]><&sp>попытка
  - else if <[number].ends_with[2]> || <[number].ends_with[3]> || <[number].ends_with[4]>:
    - define suffix <&c>Осталось<&sp><[number]><&sp>попытки
  - else if <[number].ends_with[1_]>:
    - define suffix <&c>Осталось<&sp><[number]><&sp>попыток
  - else:
    - define suffix <&c>Осталось<&sp><[number]><&sp>попыток
  - determine <[suffix]>
