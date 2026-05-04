Viewed Makefile:1-63
Edited implementation_plan.md

He preparado un plan detallado para corregir tu `Makefile`. Los cambios principales se centran en:

1.  **Cumplimiento estricto del Subject:** Cambiar el nombre del administrador de WordPress (que no puede contener "admin") y la URL (que debe ser `tu_login.42.fr`).
2.  **Seguridad profesional:** Eliminar las contraseñas escritas en texto plano en el `Makefile`. En su lugar, el `setup` generará contraseñas aleatorias seguras usando `openssl` si no existen los archivos. Esto garantiza que no haya credenciales en tu repositorio Git.
3.  **Limpieza quirúrgica:** Cambiar el `docker system prune -a` (que borra todo lo de la máquina) por comandos que solo afecten a este proyecto, evitando problemas si el evaluador tiene otros contenedores.

Puedes revisar los detalles técnicos en el [implementation_plan.md](file:///home/daruuu/.gemini/antigravity/brain/1a8e5688-3d6d-46e0-a968-80f12c0eb0d1/implementation_plan.md).

¿Te parece bien que proceda con estos cambios?


# Fix Makefile for Inception Project

This plan addresses the critical compliance issues and professional best practices identified in the analysis of the Makefile.

## User Review Required

> [!IMPORTANT]
> The Makefile will now generate **random passwords** using `openssl` if the secret files are missing. This is a secure approach that prevents hardcoding credentials in the Git repository.

## Proposed Changes

### Root Directory

#### [MODIFY] [Makefile](file:///home/daruuu/PhpstormProjects/Inception-ana/Makefile)
- **Change `WP_ADMIN_USER`**: Set to a name that doesn't contain "admin" (e.g., `anamedin_boss`).
- **Change `WP_URL`**: Set to `anamedin.42.fr` instead of `localhost`.
- **Remove Hardcoded Passwords**: Use `openssl rand -base64` to generate secrets dynamically if they don't exist.
- **Surgical Cleanup**: Replace `docker system prune -a` with `docker compose down --rmi all -v` to avoid deleting images/volumes from other projects.
- **Data Persistence**: Ensure `fclean` removes the specific data directory but `clean` only stops and removes containers/images.

## Verification Plan

### Automated Tests
- Run `make setup` and verify that `.env` and `srcs/secrets/` are created with correct values and random passwords.
- Run `make build` and `make all` to ensure the project still starts correctly.
- Run `make clean` and verify that only the project containers and images are removed.
- Run `make fclean` and verify that the data directory is removed.

### Manual Verification
- Check the generated `.env` file to confirm `WP_ADMIN_USER` and `WP_URL` are correct.
- Check the contents of `srcs/secrets/` to confirm random passwords were generated.
