# 🛡️ Política de Seguridad — ProjectJaina_MemoryGuard

1. **Aislamiento de Proceso:** El AddOn opera exclusivamente dentro del sandbox seguro de la API Lua de Blizzard. No inyecta DLLs, no lee memoria fuera del heap de Lua y no interactúa con procesos externos.
2. **Seguridad en Combate:** No modifica tablas seguras ni ejecuta acciones protegidas durante el combate.
