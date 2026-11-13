-- 33_carga_afirmacoes_T001_v1.0.sql : liga as afirmacoes (com trecho literal) ao rascunho mais recente de cada tipo do T001.
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A1', $af$Revisão sistemática com 19 estudos e 92.614 pacientes sobre programas de suporte de vida no trauma (ATLS o mais comum).$af$, '2026_24', $af$we identified and included 19 eligible studies. There were 92,614 patients cumulatively across the 19 studies$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A11', $af$Em revisão de revisões, a abordagem estruturada por checklist pode melhorar a adesão a diretrizes durante a ressuscitação (certeza baixa da evidência).$af$, '2023_62', $af$The application of a structured approach by checklist may improve adherence to guidelines$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A16', $af$O uso do WHO Trauma Care Checklist foi favorecido por campeão institucional, adaptação ao contexto e integração às rotinas e à documentação.$af$, '2020_40', $af$Presence of an institutional champion, context-specific adaptation, and integration of the TCC with existing care and documentation practices contribute to successful utilization.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A20', $af$Meta-análise de coortes retrospectivas: sem diferença de sobrevida entre líder cirurgião e não cirurgião (OR 0,82; IC 95% 0,61-1,10).$af$, '2017_75', $af$no difference in survival [odds ratio (OR): 0.82, 95% confidence interval (CI) 0.61-1.10, P=0.19]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A28', $af$A cricotireoidostomia/via aérea cirúrgica de emergência ocorreu em 467 pacientes (0,24%) de uma coorte retrospectiva japonesa.$af$, '2020_18', $af$emergency front-of-neck airway occurred in 467 patients (0.24%)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A40', $af$Entre 3976 pacientes com TC de corpo inteiro, 120 (3,02%) tinham avaliação primária sem alterações e nenhum teve lesão à imagem.$af$, '2024_48', $af$From 3976 patients treated with WBCT, 120 patients (3.02%) showed an inconspicuous primary survey.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A44', $af$Treinamento in situ baseado em checklist e baseado em algoritmo produziu ganhos de curto prazo semelhantes nos modelos mentais compartilhados da equipe.$af$, '2026_10', $af$Checklist- and algorithm-based formats produced similar short-term gains.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A1', $af$Revisão sistemática com 19 estudos e 92.614 pacientes sobre programas de suporte de vida no trauma (ATLS o mais comum).$af$, '2026_24', $af$we identified and included 19 eligible studies. There were 92,614 patients cumulatively across the 19 studies$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A1', $af$Revisão sistemática com 19 estudos e 92.614 pacientes sobre programas de suporte de vida no trauma (ATLS o mais comum).$af$, '2026_24', $af$we identified and included 19 eligible studies. There were 92,614 patients cumulatively across the 19 studies$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='item' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A16', $af$O uso do WHO Trauma Care Checklist foi favorecido por campeão institucional, adaptação ao contexto e integração às rotinas e à documentação.$af$, '2020_40', $af$Presence of an institutional champion, context-specific adaptation, and integration of the TCC with existing care and documentation practices contribute to successful utilization.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A28', $af$A cricotireoidostomia/via aérea cirúrgica de emergência ocorreu em 467 pacientes (0,24%) de uma coorte retrospectiva japonesa.$af$, '2020_18', $af$emergency front-of-neck airway occurred in 467 patients (0.24%)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A16', $af$O uso do WHO Trauma Care Checklist foi favorecido por campeão institucional, adaptação ao contexto e integração às rotinas e à documentação.$af$, '2020_40', $af$Presence of an institutional champion, context-specific adaptation, and integration of the TCC with existing care and documentation practices contribute to successful utilization.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A20', $af$Meta-análise de coortes retrospectivas: sem diferença de sobrevida entre líder cirurgião e não cirurgião (OR 0,82; IC 95% 0,61-1,10).$af$, '2017_75', $af$no difference in survival [odds ratio (OR): 0.82, 95% confidence interval (CI) 0.61-1.10, P=0.19]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A28', $af$A cricotireoidostomia/via aérea cirúrgica de emergência ocorreu em 467 pacientes (0,24%) de uma coorte retrospectiva japonesa.$af$, '2020_18', $af$emergency front-of-neck airway occurred in 467 patients (0.24%)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A44', $af$Treinamento in situ baseado em checklist e baseado em algoritmo produziu ganhos de curto prazo semelhantes nos modelos mentais compartilhados da equipe.$af$, '2026_10', $af$Checklist- and algorithm-based formats produced similar short-term gains.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='simulado' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A1', $af$Revisão sistemática com 19 estudos e 92.614 pacientes sobre programas de suporte de vida no trauma (ATLS o mais comum).$af$, '2026_24', $af$we identified and included 19 eligible studies. There were 92,614 patients cumulatively across the 19 studies$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A3', $af$Estudo piloto de viabilidade de ensaio randomizado por conglomerados (ATLS, PTC e cuidado padrão) incluiu 376 pacientes e 22 residentes.$af$, '2025_36', $af$We included 376 patients and 22 residents.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A6', $af$O custo de implementação de programas de treinamento variou de USD 3,70 (primeiro respondedor leigo) a USD 1433,5 (ATLS).$af$, '2026_42', $af$starting from USD 3.70 (Lay-First-Responder) to USD 1433.5 (Advanced Trauma Life Support)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A11', $af$Em revisão de revisões, a abordagem estruturada por checklist pode melhorar a adesão a diretrizes durante a ressuscitação (certeza baixa da evidência).$af$, '2023_62', $af$The application of a structured approach by checklist may improve adherence to guidelines$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A16', $af$O uso do WHO Trauma Care Checklist foi favorecido por campeão institucional, adaptação ao contexto e integração às rotinas e à documentação.$af$, '2020_40', $af$Presence of an institutional champion, context-specific adaptation, and integration of the TCC with existing care and documentation practices contribute to successful utilization.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A20', $af$Meta-análise de coortes retrospectivas: sem diferença de sobrevida entre líder cirurgião e não cirurgião (OR 0,82; IC 95% 0,61-1,10).$af$, '2017_75', $af$no difference in survival [odds ratio (OR): 0.82, 95% confidence interval (CI) 0.61-1.10, P=0.19]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A22', $af$A sobrevida no grupo com colaboração próxima entre radiologia intervencionista e cirurgia foi 15,5% maior que a prevista (IC 95% 7,5–23,6%).$af$, '2024_64', $af$the survival rate in the CG was 15.5% higher than the Ps (95% CI: 7.5–23.6%; p < 0.001)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A28', $af$A cricotireoidostomia/via aérea cirúrgica de emergência ocorreu em 467 pacientes (0,24%) de uma coorte retrospectiva japonesa.$af$, '2020_18', $af$emergency front-of-neck airway occurred in 467 patients (0.24%)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A40', $af$Entre 3976 pacientes com TC de corpo inteiro, 120 (3,02%) tinham avaliação primária sem alterações e nenhum teve lesão à imagem.$af$, '2024_48', $af$From 3976 patients treated with WBCT, 120 patients (3.02%) showed an inconspicuous primary survey.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A44', $af$Treinamento in situ baseado em checklist e baseado em algoritmo produziu ganhos de curto prazo semelhantes nos modelos mentais compartilhados da equipe.$af$, '2026_10', $af$Checklist- and algorithm-based formats produced similar short-term gains.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.status='rascunho'
   AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo=a.tipo AND x.status='rascunho')
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto=EXCLUDED.texto, fonte_arquivo=EXCLUDED.fonte_arquivo, trecho_literal=EXCLUDED.trecho_literal;
COMMIT;
