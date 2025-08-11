# SMLM5 - Scripts para SUSE Manager

Este repositório contém scripts em Bash e Python para integração com a API do SUSE Manager, facilitando o inventário e a automação de tarefas administrativas.

## Scripts principais

- **list_system_full_by_api.bash**  
  Script Bash que lista sistemas registrados no SUSE Manager, exibindo nome, ID e IP real.

- **list_system_by_api.py**  
  Script Python que lista sistemas registrados, mostrando nome, ID, release e IP.

- **update_git.bash**  
  Automatiza o processo de commit, pull e push no repositório Git, garantindo que os testes Python passem antes de atualizar o repositório.

## Requisitos

- Bash, curl, xmlstarlet (para scripts Bash)
- Python 3.x (para scripts Python)
- Acesso à API do SUSE Manager
- Git

## Uso

Veja instruções detalhadas no início de cada script.

## Como contribuir

Consulte o arquivo [CONTRIBUTING.md](CONTRIBUTING.md).

## Licença

Distribuído sob a licença GNU AGPL v3. Veja [LICENSE](LICENSE) para mais detalhes.
