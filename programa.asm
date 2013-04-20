code
inicio:
  move r0, '0'
repetir:
  out 0, r0
  call retardo
  add r0, 1
  cmp r0, '9' +  1
  jb repetir
  jmp inicio

retardo:
  move r15, 256   ;Carga el valor inicial de conteo sobre r15
  move r14, 0     ;Limpia el valor de r14

  sub r14, 1      ;Substrae 1 de r14 (provoca un desbordamiento en la primera iteracion)
  jmpnz $-1       ;Repite el proceso hasta que r14 sea 0 nuevamente

  sub r15, 1      ;Substrae 1 de r15
  jmpnz $-4       ;Repite el proceso (salta 4 instrucciones atras) hasta que r14 sea 0
  return          ;Retorna tras terminar los conteos