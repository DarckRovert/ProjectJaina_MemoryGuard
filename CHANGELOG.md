# 📝 Registro de Cambios (Changelog) — ProjectJaina_MemoryGuard

Todos los cambios notables de este componente están documentados en este archivo.

---

## [1.1.0] — 2026-11-09
### Resiliencia y Comandos Canónicos Bilingües (Hito #340)
- **Comandos de barra universales:** Registro de los alias canónicos `/mem`, `/memoria`, `/memory`, `/pjmem` y `/memoryguard`.
- **Subcomandos bilingües:** Soporte nativo para forzar purga manual (`limpiar`, `purgar`, `collect`, `purge`) y alternar modo depuración (`depurar`, `debug`).
- **Feedback de telemetría:** Mensajes de estado detallando memoria en uso (MB), estado de combate y purgas diferidas.
- **Protección de Heap:** Ejecución incremental de GC y recolección segura sincronizada con pantallas de carga.

---

## [1.0.0] — 2026-10-31
### Lanzamiento Inicial Soberano
- Centinela de recolección de basura Lua event-driven con cero tartamudeo en combate.
- Sincronización de purgas masivas con pantallas de carga y transiciones de área.
- Algoritmo de pacing incremental cada 30 segundos fuera de combate (umbral 45 MB).
- Comandos de barra `/pjmem` para inspección y control manual.
- Publicación oficial en GitHub como repositorio sovereign `DarckRovert/ProjectJaina_MemoryGuard`.
