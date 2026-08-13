# nixos-htpc

Mini PC AMD → box de sofá estilo "Android TV": boot direto para Kodi
(standalone, GBM, sem X11/desktop), Moonlight lançável a partir do Kodi,
tudo controlável por gamepad.

## Arquitetura

- `greetd` faz autologin do user `htpc` (sem privilégios) no tty1 e lança
  um wrapper de sessão em loop.
- O wrapper corre `kodi-gbm` (dono direto do DRM: refresh-rate switching
  automático, VAAPI, scanout sem compositor).
- O addon **Moonlight** (Add-ons → Programas) escreve um flag em
  `$XDG_RUNTIME_DIR` e sai do Kodi; o wrapper lança `moonlight-qt` em
  KMS (Qt eglfs); quando o Moonlight fecha, o Kodi volta.
- Desligar a box: menu de energia do Kodi (via logind, sem privilégios).

## Instalar

```sh
sudo nixos-rebuild switch --flake .#htpc
```

Se substituíres o disco/instalação, regenera `hardware-configuration.nix`
com `nixos-generate-config` e substitui o deste repo.

## Passos manuais únicos (inevitáveis)

1. **Ativar addons no Kodi** — na primeira execução: Add-ons → Os meus
   add-ons → ativar *Jellyfin* e *Moonlight* (addons geridos pelo Nix
   aparecem instalados mas desativados na primeira vez).
2. **Jellyfin** — ao ativar, indicar o endereço do servidor e fazer login.
3. **Moonlight** — lançar (Add-ons → Programas → Moonlight), adicionar o
   PC de jogos e introduzir o PIN mostrado no host.
4. **Gamepads Bluetooth** — uma vez, via SSH:

   ```sh
   bluetoothctl
   scan on          # pôr o comando em modo pairing
   pair XX:XX:...
   trust XX:XX:...  # religa automaticamente a partir daqui
   connect XX:XX:...
   ```

   O emparelhamento persiste em `/var/lib/bluetooth`.

## CEC (comando da TV)

O Kodi vem compilado com libcec, mas o HDMI de iGPUs x86 **não expõe o
pino CEC** — sem um adaptador [Pulse-Eight USB-CEC](https://www.pulse-eight.com/p/104/usb-hdmi-cec-adapter)
(~40€) o comando da TV não funciona. Com o adaptador ligado é
plug-and-play (o user `htpc` já está no grupo `dialout`).

## Notas

- Vulkan via RADV e VAAPI via Mesa (`hardware.graphics.enable`) — sem
  amdvlk nem ROCm, deliberadamente.
- Wi-Fi: a config usa DHCP em todas as interfaces; para gerir redes
  Wi-Fi, ativar `networking.networkmanager.enable` e usar `nmtui` por SSH.
- Gamepads Xbox por BT: se derem problemas, ativar `hardware.xpadneo.enable`.
- Escape hatch: Ctrl+Alt+F2 dá uma consola de login normal.
