# SMLM5 - Scripts para SUSE Manager

Este repositório reúne scripts em Bash e Python para integração, automação e geração de relatórios no SUSE Manager, facilitando inventário de sistemas, administração de usuários e exportação de dados.

## Scripts disponíveis

### Bash

- **list_system_full_by_api.bash**  
  Lista todos os sistemas registrados no SUSE Manager, exibindo nome, ID e IP real. Útil para inventário rápido e conferência de ativos.

- **update_git.bash**  
  Automatiza operações Git: realiza commit, pull e push no repositório, garantindo que os testes Python sejam executados e aprovados antes de atualizar o repositório remoto.

- **generate-spacewalk-reports-4.3.bash**  
  Gera todos os relatórios disponíveis do Spacewalk no SUSE Manager 4.3, salvando-os em formato CSV em uma pasta com timestamp. Após a geração, compacta os arquivos em `.tar.gz` e remove a pasta original para otimizar espaço.

- **generate-spacewalk-reports-5.0.5.bash**  
  Executa dentro do container Uyuni Server no SUSE Manager 5.0.5. Gera relatórios Spacewalk em CSV, compacta em `.tar.gz`, remove a pasta original e orienta como copiar o arquivo para o host usando `mgrctl cp`.

### Python

- **list_system_by_api.py**  
  Conecta à API XML-RPC do SUSE Manager e lista todos os sistemas registrados, exibindo nome, ID, release e IP em formato de tabela. Permite inventário detalhado e exportação de dados para outros sistemas.

- **list_all_users_by_api.py**  
  Conecta à API XML-RPC do SUSE Manager e lista todos os usuários cadastrados, mostrando login, nome completo, e-mail e status da conta (ativa ou desativada). Útil para auditoria e administração de usuários.

- **get_user_details_by_api.py**  
  Conecta à API XML-RPC do SUSE Manager para buscar e exibir os detalhes de um usuário específico. Mostra login, nome completo, e-mail, status da conta (ativa ou desativada) e os papéis administrativos atribuídos.  
  **Uso:**  
  ```bash
  python3 get_user_details_by_api.py <username>
  ```

## Requisitos

- Bash, curl, xmlstarlet (para scripts Bash)
- Python 3.x (para scripts Python)
- Acesso à API do SUSE Manager
- Git
- Comando `spacewalk-report` disponível (para scripts de relatório)

## Uso

Consulte instruções detalhadas no início de cada script.

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

### Inventário de sistemas e usuários

#### Listar sistemas

```bash
python3 list_system_by_api.py
```

#### Listar usuários

```bash
python3 list_all_users_by_api.py
```

#### Detalhes de um usuário específico

```bash
python3 get_user_details_by_api.py <username>
```

## Como contribuir

Consulte o arquivo [CONTRIBUTING.md](CONTRIBUTING.md).

## Licença

Distribuído sob a licença GNU AGPL v3. Veja [LICENSE](LICENSE) para mais