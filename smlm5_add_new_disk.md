## Guia: Adicionar e Configurar Disco de Armazenamento para Pacotes no SUSE Manager (VirtualBox)

Este guia detalha o processo de adicionar um novo disco de 100GB a uma máquina virtual (VM) existente do SUSE Manager 5.0.4.1 em SLES Micro 5.5, executando no VirtualBox 7.1.10. O objetivo é configurar este novo disco para que ele seja o local de armazenamento principal para os pacotes e canais de software do SUSE Manager, que é implantado de forma contêinerizada via Podman.

**Cenário Detalhado:**
Você possui uma VM no VirtualBox (versão 7.1.10) em um host Windows 11. Nesta VM, está instalado o SLES Micro 5.5, que é um sistema operacional leve e imutável, otimizado para cargas de trabalho de contêineres. Sobre o SLES Micro, o SUSE Manager 5.0.4.1 está instalado e funcional em um ambiente contêinerizado (gerenciado pelo Podman). Atualmente, a VM possui apenas um disco de 20GB, e você precisa expandir o armazenamento para acomodar os produtos e canais de software do SUSE Manager, que ainda não foram adicionados. O novo disco de 100GB será configurado para ser montado no local onde o SUSE Manager espera armazenar esses pacotes.

**Versões Utilizadas:**
* **Host:** Windows 11
* **VirtualBox:** 7.1.10
* **Guest OS (VM):** SLES Micro 5.5
* **SUSE Manager:** 5.0.4.1 (contêinerizado)

---

### Parte 1: Configuração no VirtualBox (Host - Windows 11)

1.  **Desligue a Máquina Virtual (VM):**
    * No VirtualBox Manager, selecione sua VM (`suma5`).
    * Certifique-se de que a VM esteja **completamente desligada** (não em estado salvo ou pausada).

2.  **Adicionar Novo Disco Rígido Virtual:**
    * Com a VM selecionada, clique em **"Configurações" (Settings)**.
    * Vá para a seção **"Armazenamento" (Storage)**.
    * Sob o controlador **"SATA"**, clique no ícone **"Adicionar Hard Disk"** (o pequeno ícone com um `+` verde).
    * Selecione **"Criar Novo Disco" (Create New Disk)**.
    * Escolha **"VDI (VirtualBox Disk Image)"** como tipo de arquivo e clique em "Próximo".
    * Selecione **"Dinamicamente alocado" (Dynamically allocated)** e clique em "Próximo".
    * Defina o nome do arquivo (ex: `suma5_data.vdi`) e o **tamanho para 100 GB**. Clique em "Criar".
    * Selecione o disco recém-criado na lista e clique em **"Escolher" (Choose)**.
    * Clique em **"OK"** para fechar as configurações da VM.

---

### Parte 2: Configuração no SLES Micro (Sistema Operacional Convidado da VM)

1.  **Inicie a VM** e conecte-se via SSH ou console.

2.  **Identifique o Novo Disco:**
    * O novo disco deve aparecer como `/dev/sda` (ou `/dev/sdb` se já houver um `sda` existente além do disco de root).
    * Verifique com o comando:
        ```bash
        sudo fdisk -l
        ```
    * Identifique o disco de 100GB. Neste guia, assumimos que é `/dev/sda`.

3.  **Crie uma Partição no Novo Disco:**
    ```bash
    sudo fdisk /dev/sda
    ```
    * Pressione `n` (nova partição).
    * Pressione `p` (partição primária).
    * Pressione `1` (primeira partição).
    * Pressione `Enter` duas vezes (para usar os setores padrão e o disco inteiro).
    * Pressione `w` (gravar as mudanças e sair).

4.  **Formate a Nova Partição:**
    * Recomenda-se `xfs` para volumes de dados de servidor.
    ```bash
    sudo mkfs.xfs /dev/sda1
    ```

5.  **Obtenha o UUID da Nova Partição:**
    * Este UUID é necessário para a montagem persistente.
    ```bash
    sudo blkid /dev/sda1
    ```
    * Anote o UUID (ex: `16d14894-7cbd-4fba-a7c4-c0b5f4c677c5`).

6.  **Crie o Diretório de Montagem para o Volume do Podman:**
    * O SUSE Manager (contêinerizado via Podman) espera que os dados dos canais sejam armazenados em um subdiretório `_data` dentro do volume `srv-spacewalk`.
    ```bash
    sudo mkdir -p /var/lib/containers/storage/volumes/srv-spacewalk/_data
    ```

7.  **Ajuste as Permissões do Diretório de Montagem:**
    * É crucial que o usuário `10552` (proprietário do volume `srv-spacewalk` no contêiner) tenha acesso de escrita.
    ```bash
    sudo chown 10552:root /var/lib/containers/storage/volumes/srv-spacewalk/_data
    sudo chmod 755 /var/lib/containers/storage/volumes/srv-spacewalk/_data
    ```

8.  **Configure a Montagem Persistente no `/etc/fstab`:**
    * Abra o arquivo `fstab` para edição:
    ```bash
    sudo vim /etc/fstab
    ```
    * Adicione a seguinte linha no final do arquivo, substituindo `SEU_UUID_AQUI` pelo UUID real que você obteve:
        ```
        UUID="SEU_UUID_AQUI" /var/lib/containers/storage/volumes/srv-spacewalk/_data xfs defaults 0 0
        ```
        *Exemplo com o UUID do guia:*
        ```
        UUID="16d14894-7cbd-4fba-a7c4-c0b5f4c677c5" /var/lib/containers/storage/volumes/srv-spacewalk/_data xfs defaults 0 0
        ```
    * Salve e feche o arquivo.

9.  **Monte o Novo Disco e Verifique:**
    * Monte todas as entradas no `fstab`:
        ```bash
        sudo mount -a
        ```
    * Verifique se o novo disco está montado corretamente:
        ```bash
        df -h /var/lib/containers/storage/volumes/srv-spacewalk/_data
        ```
    * Confirme que `/dev/sda1` (ou seu disco correspondente) está montado no local especificado com 100GB de tamanho.

---

### Parte 3: Reconfiguração e Início do SUSE Manager (Contêiner)

1.  **Parar o SUSE Manager (se estiver em execução):**
    ```bash
    sudo mgradm stop
    ```

2.  **Iniciar o SUSE Manager:**
    * Com o disco montado e permissões corretas, inicie o SUSE Manager.
    ```bash
    sudo mgradm start
    ```

3.  **Verificar o Status do SUSE Manager:**
    * Aguarde alguns minutos para que todos os serviços subam completamente.
    ```bash
    sudo mgradm status
    ```
    * Todos os serviços principais (Tomcat, Salt Master, Apache2, Taskomatic, etc.) devem estar `active (running)` ou `active (exited)` com `status=0/SUCCESS`.

---

**Conclusão:**

O SUSE Manager agora está configurado para utilizar o novo disco de 100GB montado em `/var/lib/containers/storage/volumes/srv-spacewalk/_data` para armazenar seus canais e pacotes de software. Você pode prosseguir com a adição de produtos e canais através da interface web do SUSE Manager.

**Conclusão:**

O SUSE Manager agora está configurado para utilizar o novo disco de 100GB montado em `/var/lib/containers/storage/volumes/srv-spacewalk/_data` para armazenar seus canais e pacotes de software. Você pode prosseguir com a adição de produtos e canais através da interface web do SUSE Manager.

---
