<p align="center">
  <img src="https://raw.githubusercontent.com/DarckRovert/ProjectJaina_Web/main/images/project_jaina_official_logo.jpg" alt="Project JAIna Official Crest" width="180">
</p>

# Project Jaina — Memory Guard (`ProjectJaina_MemoryGuard`)

[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)](https://github.com/DarckRovert/ProjectJaina_MemoryGuard)
[![Engine](https://img.shields.io/badge/Engine-JainaCore%203.3.5a-blue.svg)](https://github.com/DarckRovert/JainaCore_Server)
[![Client](https://img.shields.io/badge/Client-WotLK%20HD%2FFHD-purple.svg)](https://github.com/DarckRovert/ProjectJaina_Lab)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Centinela Inteligente de Memoria Virtual y Recolección Agresiva de Basura Lua (Anti-OOM) para World of Warcraft 3.3.5a.**

---

## 1. Visión y Propósito Arquitectónico

El cliente oficial de **Project Jaina** integra un paquete masivo de texturas, modelos y sonido en alta definición (23.8 GB FHD). En el cliente 3.3.5a de World of Warcraft, el motor de interfaz ejecuta un entorno Lua 5.1 con límites de memoria de heap compartidos con el espacio de direcciones de 32 bits del ejecutable (`Wow.exe`), lo que en sesiones prolongadas con addons complejos (DBM, Carbonite, GearScore, DragonflightUI) puede provocar fragmentación de memoria y errores críticos de tipo **Out of Memory (OOM)**.

`ProjectJaina_MemoryGuard` actúa como un centinela no invasivo de recolección de basura con tolerancia cero al tartamudeo (*zero stutter*).

---

## 2. Principios de Ingeniería (Estándar L9)

1. **Zero Stutter en Combate (`InCombatLockdown`):**
   - NUNCA ejecuta ciclos completos de recolección forzada (`collectgarbage("collect")`) durante encuentros de combate o PvP. Si el umbral de memoria se sobrepasa durante un encuentro, la purga se difiere en cola y se dispara de forma atómica en el evento `PLAYER_REGEN_ENABLED`.
2. **Event-Driven Purging en Transiciones de Fase:**
   - Sincroniza la recolección profunda con las pantallas de carga (`PLAYER_ENTERING_WORLD` y `ZONE_CHANGED_NEW_AREA`), liberando tablas y texturas temporales en el instante en que el usuario ya está esperando la carga.
3. **Paced GC fuera de Combate:**
   - Fuera de combate, ejecuta pasos incrementales de pacing (`collectgarbage("step", 150)`) cada 30 segundos si el heap supera los 45 MB, manteniendo la memoria lineal y previniendo picos de lag.
4. **Cero Allocations Dinámicas:**
   - El frame centinela utiliza acumuladores estáticos en `OnUpdate` sin instanciar tablas temporales en el heap de Lua.

---

## 3. Comandos de Consola (Slash Commands)

| Comando | Acción |
| :--- | :--- |
| `/pjmem` o `/memoryguard` | Muestra el estado del centinela, uso actual de memoria y combate. |
| `/pjmem collect` o `/pjmem purge` | Fuerza una purga inmediata si está fuera de combate (o la encola si está en combate). |
| `/pjmem debug` | Alterna el modo de telemetría y reportes detallados en el chat. |

---

## 4. Instalación

1. Clona o copia la carpeta `ProjectJaina_MemoryGuard` dentro del directorio de addons del cliente:
   ```text
   Interface\AddOns\ProjectJaina_MemoryGuard\
   ```
2. Asegúrate de que los siguientes archivos estén presentes:
   - `ProjectJaina_MemoryGuard.toc`
   - `ProjectJaina_MemoryGuard.lua`
   - `README.md`
   - `LICENSE`
3. Inicia el cliente del juego y verifica su estado mediante el comando `/pjmem`.

---

## 5. Licencia

Distribuido bajo la Licencia **MIT**. Consulta el archivo [`LICENSE`](LICENSE) para más detalles.
Copyright (c) 2026 DarckRovert & Project Jaina Dev Team.
