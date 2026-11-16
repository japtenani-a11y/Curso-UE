# T001 · Atualização de 16/11/2026

Nova versão de todo o material do T001, em rascunho, na pasta `conteudo/T001/` (formato do importador).

## O que mudou

| Peça | Mudança |
|---|---|
| Objetivos | Um objetivo de aula por perfil (técnica e anatomia); citações das fontes novas |
| Resumo básico | Consenso de 2025 (circulação antes da via aérea invasiva), tamponamento, pulsos, instável não vai à TC |
| Podcast | Trecho novo sobre o consenso e o REACT-2 |
| Caso base | Duas perguntas novas (posição do torniquete; intubar ou não) |
| Síntese de evidência | Camadas 3 e 5 agora com fonte; disputa CAB contra ABC; REACT-2; seção "O que mata na sala de trauma" |
| Mapa | Ramos novos: ordem, erros que matam |
| Aula (texto) | Reescrita: não repete a teoria. Oito seções de decisão, técnica e anatomia |
| Slides | Reescritos: 15 slides com fala, sobre o caso, hemorragia externa, torniquete, pelve, acesso, tórax, via aérea cirúrgica, destino e erro |
| Caso da aula | Novo: fratura de pelve em choque, com seis pontos de decisão |
| Resumo executivo, checklist, flashcards | Atualizados com a técnica da aula |
| Protocolo | Passos de hemorragia, via aérea e circulação detalhados; protocolo de transfusão maciça do Hospital de Base; indicadores |

## Fontes

- 59 afirmações novas, cada uma com o trecho literal conferido no texto da fonte: 163 no total.
- Diretriz e consenso (G1 a G11): WSES-PTS 2025, protocolo AAST/ACS-COT de ressuscitação de controle de danos, indicadores da WSES.
- Artigos (A48 a A56): REACT-2, Gruen 2006, Teixeira 2007, Tignanelli 2018, Demetriades 2004.
- Livro-texto (D42 a D75): Mattox 9ª ed., capítulos 10, 13, 14, 18, 28, 39 e 45; manual do European Trauma Course, capítulo 1.
- Protocolo e ficha do serviço (P16 a P21): transfusão maciça do Hospital de Base; ficha da sala de trauma.

## Questões

- 193 questões: as 170 anteriores, 20 novas sobre o conteúdo da aula (uma por perfil nos testes 3 a 6) e 3 âncoras.
- Alternativas reescritas para ficarem de tamanho parecido. A correta era a mais longa em 87% das questões e, em média, 2,75 vezes maior que as erradas; agora é a mais longa em 20% (o esperado ao acaso) e 1,14 vez maior.
- O sentido de cada alternativa foi mantido, para as justificativas continuarem válidas. As alternativas reescritas precisam da leitura de um revisor.

## Como gravar

```
cd ~/Curso-UE
bash fontes_do_tema_v1.0.sh T001 SENHA
bash importar_tema_v1.0.sh T001 SENHA
bash importar_tema_v1.0.sh T001 SENHA --aplicar
```

As peças entram em rascunho, como versão nova. O que está publicado continua valendo até a revisão e a publicação.

## Pendências para a revisão

- Os trechos do Mattox não são conferidos pelo importador (o livro não está no banco): o revisor confere no capítulo.
- A extrapolação do consenso de 2025 ao trauma fechado com possível TCE está marcada no caso da aula como ponto de cautela.
- Gruen 2006 e Teixeira 2007 têm mais de dez anos.
