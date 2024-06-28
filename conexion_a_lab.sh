#!/bin/bash

# Variables
#definir variables de entorno agregandolas a .bashrc
#USUARIO_LOCAL="user"
#USUARIO_SERVIDOR_CONEXION="dochoa"
#USUARIO_LAB="sysadmin"
#PASSWORD_SERVIDOR_CONEXION="Welcome1"
#PASSWORD_LAB="Li69nux*1234"
#IP_SERVIDOR_CONEXION="128.224.151.254"
IP_LAB="$1"
TIMEOUT="15"

# Validar entrada de IP del host final
if [ -z "$IP_LAB" ]; then
  echo "Introducir ip del lab"
  exit 1
fi

echo "Paso 1: Copiar clave pública al servidor de conexión desde el equipo local"
sshpass -p "$PASSWORD_SERVIDOR_CONEXION" ssh-copy-id "$USUARIO_SERVIDOR_CONEXION@$IP_SERVIDOR_CONEXION"

echo "Paso 2: Copiar clave pública al LAB desde el servidor de conexión"
sshpass -p "$PASSWORD_SERVIDOR_CONEXION" ssh "$USUARIO_SERVIDOR_CONEXION@$IP_SERVIDOR_CONEXION" "
  sshpass -p '$PASSWORD_LAB' ssh-copy-id $USUARIO_LAB@$IP_LAB
"


echo "Paso 3: Copiar authorized_keys desde el servidor de conexión al LAB"
sshpass -p "$PASSWORD_SERVIDOR_CONEXION" ssh -A "$USUARIO_SERVIDOR_CONEXION@$IP_SERVIDOR_CONEXION" "
  sshpass -p '$PASSWORD_LAB' ssh -o StrictHostKeyChecking=no $USUARIO_LAB@$IP_LAB 'mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys'
  cat ~/.ssh/authorized_keys | sshpass -p '$PASSWORD_LAB' ssh $USUARIO_LAB@$IP_LAB 'cat >> ~/.ssh/authorized_keys'
"


echo "Paso 4: Probar la conexión desde el equipo local"
if ssh -o BatchMode=yes -o ConnectTimeout=$TIMEOUT -J "$USUARIO_SERVIDOR_CONEXION@$IP_SERVIDOR_CONEXION" "$USUARIO_LAB@$IP_LAB" true; then
    echo "Para conectarte al lab usar:"
    echo "ssh -J $USUARIO_SERVIDOR_CONEXION@$IP_SERVIDOR_CONEXION $USUARIO_LAB@$IP_LAB"
else
    echo "No se pudo establecer la conexión sin contraseña, probar aumentando el TIMEOUT "
fi
