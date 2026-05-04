
``` text
dado el siguiente caso a probar: me gustaria modificar uno de los servicios que tengo,
uno de lo puertos , cual servicio me recomiendas modificar y la idea es 
que al modificar el puerto del servicio, al reiniciar la maquina 
virtual y hacer un make fclean, el puerto nuevo este actualizado en el sistema.
```


Esta es una excelente prueba para demostrar que tu infraestructura es **flexible y está bien parametrizada**, algo que los evaluadores de 42 valoran mucho (y que es un estándar en la industria).

### Mi recomendación: Modifica el puerto de NGINX

Aunque el *Subject* exige el puerto 443 para la entrega final, es el servicio más interesante de modificar para una prueba porque el cambio es **inmediatamente visible** en el navegador.

Para que este cambio persista tras un `make fclean` y un reinicio, debemos **evitar el hardcoding** (valores fijos) en los archivos de configuración.

### Cómo implementarlo paso a paso:

#### 1. Parametrizar el puerto en el `.env`
En lugar de tener el puerto fijo, lo definiremos como una variable. En tu `Makefile`, en la sección donde se crea el `.env`, añade:
```makefile
echo "NGINX_PORT=443" >> srcs/.env;
```

#### 2. Usar la variable en `docker-compose.yml`
Modifica la sección de `nginx` para que use esa variable:
```yaml
nginx:
  # ...
  ports:
    - "${NGINX_PORT}:443" # Mapea el puerto del host (variable) al 443 del contenedor
```

#### 3. El flujo de la prueba que planteas:
Si quieres que al hacer `make fclean` el puerto nuevo **permanezca**, tienes dos opciones profesionales:

*   **Opción A (La más pro):** No borres el `.env` en el `fclean`. En el mundo real, `fclean` debería borrar imágenes y volúmenes, pero a veces conservamos el `.env` precisamente para no perder la configuración local.
*   **Opción B (La de evaluación):** Modifica el valor por defecto en el **Makefile**. Si cambias `echo "NGINX_PORT=443"` por `echo "NGINX_PORT=8443"` en el `Makefile`, cada vez que hagas `fclean` y `all`, el sistema se levantará en el 8443 automáticamente.

### ¿Por qué NGINX y no otro?
*   **MariaDB/WordPress:** Sus puertos suelen ser internos a la red de Docker (`inception_network`). Cambiarlos requiere modificar también los scripts de conexión (`setup.sh`), lo que aumenta la probabilidad de errores.
*   **NGINX:** Solo cambias el mapeo externo. El contenedor sigue pensando que está en el 443 (lo cual cumple con su configuración de SSL), pero el mundo exterior accede por el puerto que tú elijas.

**¿Quieres que apliquemos este cambio de "puerto dinámico" ahora mismo cuando corrijamos el Makefile?** Podría dejarlo preparado para que solo tengas que cambiar un número en el `Makefile` y todo se actualice solo.