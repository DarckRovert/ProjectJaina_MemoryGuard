# 🤖 Reglas de Contexto y Memoria para Agentes de IA — ProjectJaina_MemoryGuard

> **Documento Maestro de Arquitectura y Memoria Operativa**  
> **Ámbito:** `Client\Interface\AddOns\ProjectJaina_MemoryGuard\`  
> **Líder del Proyecto:** DarckRovert (Ingame: `Elnazzareno`)  
> **Servidor Destino:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/)  
> **Arquitectura:** Centinela Virtual Memory Garbage Collector Anti-OOM  

---

## 1. Principios Inviolables para Agentes
1. **Zero Stutter:** PROHIBIDO invocar `collectgarbage("collect")` durante `InCombatLockdown()`. Toda purga en combate debe posponerse a `PLAYER_REGEN_ENABLED`.
2. **Cero Allocations:** El bucle `OnUpdate` no debe instanciar tablas temporales ni generar basura en el heap de Lua.
3. **Pacing Incremental Fuera de Combate:** Pasos ligeros `collectgarbage("step", 150)` cada 30s si el uso excede 45 MB.
