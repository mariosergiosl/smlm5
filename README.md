# SMLM5 - Scripts para SUSE Manager

Este repositório contém scripts em Bash e Python para integração com a API do SUSE Manager, facilitando o inventário, automação de tarefas administrativas e geração de relatórios.

## Scripts principais

- **list_system_full_by_api.bash**  
  Lista sistemas registrados no SUSE Manager, exibindo nome, ID e IP real.

- **list_system_by_api.py**  
  Lista sistemas registrados, mostrando nome, ID, release e IP.

- **update_git.bash**  
  Automatiza commit, pull e push no repositório Git, garantindo que os testes Python passem antes de atualizar o repositório.

- **generate-spacewalk-reports-4.3.bash**  
  Gera todos os relatórios disponíveis do Spacewalk no SUSE Manager 4.3, salva como CSV em uma pasta com timestamp, compacta em `.tar.gz` e remove a pasta original.

- **generate-spacewalk-reports-5.0.5.bash**  
  Executa dentro do container Uyuni Server no SUSE Manager 5.0.5, gera relatórios Spacewalk, salva como CSV, compacta em `.tar.gz`, remove a pasta original e orienta como copiar o arquivo para o host usando `mgrctl cp`.

## Requisitos

- Bash, curl, xmlstarlet (para scripts Bash)
- Python 3.x (para scripts Python)
- Acesso à API do SUSE Manager
- Git
- Comando `spacewalk-report` disponível (para scripts de relatório)

## Uso

Veja instruções detalhadas no início de cada script.

### Relatórios Spacewalk

#### SUSE Manager 4.3

```bash
wget https://github.com/mariosergiosl/smlm5/blob/main/generate-spacewalk-reports-4.3.bash -O /opt/generate-spacewalk-reports-4.3.bash
chmod +x /opt/generate-spacewalk-reports-4.3.bash
/opt/generate-spacewalk-reports-4.3.bash
```

#### SUSE Manager 5.0.5 (Uyuni Server container)

```bash
mgrctl term
wget https://github.com/mariosergiosl/smlm5/blob/main/generate-spacewalk-reports-5.0.5.bash -O /opt/generate-spacewalk-reports-5.0.5.bash
chmod +x /opt/generate-spacewalk-reports-5.0.5.bash
/opt/generate-spacewalk-reports-5.0.5.bash
exit
mgrctl cp server:/opt/reports_<timestamp>.tar.gz /opt/reports_<timestamp>.tar.gz
```

## Como contribuir

Consulte o arquivo [CONTRIBUTING.md](CONTRIBUTING.md).

## Licença

Distribuído sob a licença GNU AGPL v3. Veja [LICENSE](LICENSE) para mais detalhes.
