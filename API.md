# 💻 Especificación de API — ProjectJaina_MemoryGuard

Documento técnico del centinela de recolección de basura y gestión de memoria Lua para el cliente FHD de 23.8 GB de **Project Jaina**.

---

## 1. Comandos de Barra (Slash Commands)
* `/pjmem`: Muestra el estado del centinela, consumo de memoria Lua actual (MB), estado de combate y purgas encoladas.
* `/pjmem collect` o `/pjmem purge`: Dispara una purga forzada inmediata si se encuentra fuera de combate (o la encola si está en combate).
* `/pjmem debug`: Alterna los registros de depuración detallada en el chat general.

---

## 2. Eventos Manejados
* `PLAYER_ENTERING_WORLD`: Purga masiva post-pantalla de carga de mundo.
* `ZONE_CHANGED_NEW_AREA`: Purga masiva en transiciones entre continentes o estancias.
* `PLAYER_REGEN_DISABLED`: Entrada en combate (desactiva purgas agresivas).
* `PLAYER_REGEN_ENABLED`: Salida de combate (ejecuta purgas encoladas y libera tablas de combate de DBM/GearScore).
