-- =============================================================
-- SIPAC - Datos de Ejemplo (Seed)
-- Ejecutar DESPUÉS de crear-tablas.sql
-- =============================================================

-- =============================================================
-- 1. ROLES
-- =============================================================
INSERT INTO roles (nombre, descripcion) VALUES
    ('Administrador',  'Acceso total al sistema'),
    ('Instructor',     'Puede gestionar portafolios y cuentas de cobro'),
    ('Coordinador',    'Supervisa fichas y asignaciones'),
    ('Apoyo',          'Acceso de solo lectura y notificaciones');

-- =============================================================
-- 2. ESTADOS
-- =============================================================
INSERT INTO estados (nombre) VALUES
    ('Activo'),
    ('Inactivo'),
    ('Pendiente'),
    ('Aprobado'),
    ('Rechazado'),
    ('En revisión');

-- =============================================================
-- 3. TIPOS DE ASIGNACIONES
-- =============================================================
INSERT INTO tipos_asignaciones (tipo) VALUES
    ('Titular'),
    ('Apoyo'),
    ('Temporal'),
    ('Provisional');

-- =============================================================
-- 4. TIPOS DE DOCUMENTOS
-- =============================================================
INSERT INTO tipos_documentos (nombre) VALUES
    ('Cuenta de Cobro'),
    ('Portafolio Docente'),
    ('Planilla de Asistencia'),
    ('Informe de Avance'),
    ('Certificado'),
    ('Guía de Aprendizaje');

-- =============================================================
-- 5. USUARIOS
-- contraseña almacenada como hash bcrypt (valor de ejemplo)
-- En producción el backend genera el hash real
-- =============================================================
INSERT INTO usuarios (primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, email, contrasena, rol_id, estado_id) VALUES
    ('Carlos',   'Andrés',  'Ramírez',   'Gómez',    'carlos.ramirez@sipac.edu.co',   '$2b$12$examplehash1', 1, 1),  -- Administrador
    ('María',    'Isabel',  'López',     'Torres',   'maria.lopez@sipac.edu.co',      '$2b$12$examplehash2', 2, 1),  -- Instructor
    ('Juan',     NULL,      'Martínez',  'Herrera',  'juan.martinez@sipac.edu.co',    '$2b$12$examplehash3', 2, 1),  -- Instructor
    ('Luisa',    'Fernanda','Peña',      'Castillo', 'luisa.pena@sipac.edu.co',       '$2b$12$examplehash4', 3, 1),  -- Coordinador
    ('Andrés',   NULL,      'Vargas',    'Moreno',   'andres.vargas@sipac.edu.co',    '$2b$12$examplehash5', 2, 1),  -- Instructor
    ('Paola',    'Andrea',  'Rodríguez', NULL,       'paola.rodriguez@sipac.edu.co',  '$2b$12$examplehash6', 4, 1),  -- Apoyo
    ('Felipe',   NULL,      'García',    'Ruiz',     'felipe.garcia@sipac.edu.co',    '$2b$12$examplehash7', 2, 3),  -- Instructor Pendiente
    ('Sandra',   'Milena',  'Díaz',      'Ospina',   'sandra.diaz@sipac.edu.co',      '$2b$12$examplehash8', 2, 2);  -- Instructor Inactivo

-- =============================================================
-- 6. FICHAS
-- =============================================================
INSERT INTO fichas (nombre, codigo, estado_id, created_by) VALUES
    ('Análisis y Desarrollo de Software',   '2758315', 1, 1),
    ('Sistemas',                            '2650814', 1, 1),
    ('Contabilidad y Finanzas',             '2750126', 1, 4),
    ('Gestión Logística',                   '2888342', 1, 4),
    ('Electricidad Industrial',             '2910045', 3, 1);

-- =============================================================
-- 7. FICHAS_INSTRUCTORES
-- =============================================================
INSERT INTO fichas_instructores (fichas_id, instructores_id) VALUES
    (1, 2),  -- María → ADS
    (1, 3),  -- Juan  → ADS
    (2, 3),  -- Juan  → Sistemas
    (3, 5),  -- Andrés → Contabilidad
    (4, 5);  -- Andrés → Logística

-- =============================================================
-- 8. PERIODOS
-- =============================================================
INSERT INTO periodos (nombre, fecha_inicio, fecha_fin, estado_id, created_by) VALUES
    ('2024-1', '2024-01-15', '2024-06-30', 2, 1),  -- Inactivo (cerrado)
    ('2024-2', '2024-07-08', '2024-12-15', 2, 1),  -- Inactivo (cerrado)
    ('2025-1', '2025-01-13', '2025-06-29', 1, 1),  -- Activo
    ('2025-2', '2025-07-07', '2025-12-14', 3, 1);  -- Pendiente (próximo)

-- =============================================================
-- 9. ASIGNACIONES
-- =============================================================
INSERT INTO asignaciones (usuario_id, ficha_id, tipo_asignacion_id, created_by) VALUES
    (2, 1, 1, 1),  -- María  / ADS              / Titular
    (3, 1, 2, 1),  -- Juan   / ADS              / Apoyo
    (3, 2, 1, 1),  -- Juan   / Sistemas         / Titular
    (5, 3, 1, 4),  -- Andrés / Contabilidad     / Titular
    (5, 4, 1, 4);  -- Andrés / Logística        / Titular

-- =============================================================
-- 10. CUENTAS DE COBRO
-- =============================================================
INSERT INTO cuentas_cobro (usuario_id, periodo_id, estado_id, fecha, observaciones, created_by) VALUES
    (2, 3, 3, '2025-06-20 08:00:00', NULL,                        2),  -- María  / 2025-1 / Pendiente
    (3, 3, 3, '2025-06-21 09:30:00', NULL,                        3),  -- Juan   / 2025-1 / Pendiente
    (5, 3, 4, '2025-06-18 10:00:00', 'Aprobada por coordinación', 5),  -- Andrés / 2025-1 / Aprobado
    (2, 2, 4, '2024-12-10 08:00:00', NULL,                        2),  -- María  / 2024-2 / Aprobado
    (3, 2, 5, '2024-12-11 11:00:00', 'Falta firma del director',  3);  -- Juan   / 2024-2 / Rechazado

-- =============================================================
-- 11. PORTAFOLIOS
-- =============================================================
INSERT INTO portafolios (usuario_id, ficha_id, periodo_id, estado_id, created_by) VALUES
    (2, 1, 3, 3, 2),  -- María  / ADS          / 2025-1 / Pendiente
    (3, 1, 3, 3, 3),  -- Juan   / ADS          / 2025-1 / Pendiente
    (3, 2, 3, 6, 3),  -- Juan   / Sistemas     / 2025-1 / En revisión
    (5, 3, 3, 4, 5),  -- Andrés / Contabilidad / 2025-1 / Aprobado
    (2, 1, 2, 4, 2);  -- María  / ADS          / 2024-2 / Aprobado

-- =============================================================
-- 12. FECHAS LÍMITE
-- =============================================================
INSERT INTO fechas_limite (periodo_id, tipo_documento_id, fecha, created_by) VALUES
    (3, 1, '2025-06-25 23:59:00', 1),  -- Cuenta de Cobro   / 2025-1
    (3, 2, '2025-06-28 23:59:00', 1),  -- Portafolio        / 2025-1
    (3, 3, '2025-06-20 23:59:00', 1),  -- Planilla Asistencia / 2025-1
    (4, 1, '2025-12-22 23:59:00', 1),  -- Cuenta de Cobro   / 2025-2
    (4, 2, '2025-12-24 23:59:00', 1);  -- Portafolio        / 2025-2

-- =============================================================
-- 13. NOTIFICACIONES
-- =============================================================
INSERT INTO notificaciones (usuario_id, mensaje, fecha, leida, created_by) VALUES
    (2, 'Su cuenta de cobro del periodo 2025-1 está pendiente de revisión.',     '2025-06-21 08:00:00', 0, 1),
    (3, 'Recuerde cargar el portafolio antes del 28 de junio.',                  '2025-06-22 07:30:00', 0, 1),
    (5, 'Su cuenta de cobro fue aprobada exitosamente.',                         '2025-06-19 10:00:00', 1, 1),
    (3, 'Su cuenta de cobro del periodo 2024-2 fue rechazada. Revise observaciones.', '2024-12-12 09:00:00', 1, 1),
    (2, 'Nuevo periodo 2025-2 disponible. Revise las fechas límite.',            '2025-06-01 08:00:00', 0, 1);

-- =============================================================
-- 14. DOCUMENTOS_CUENTA_COBRO
-- =============================================================
INSERT INTO documentos_cuenta_cobro (ruta, cuenta_cobro_id, tipo_documento_id, created_by) VALUES
    ('/uploads/cuentas/2025/cc_001_gf.pdf', 1, 1, 2),
    ('/uploads/cuentas/2025/cc_002_gc.pdf', 2, 1, 3),
    ('/uploads/cuentas/2024/cc_004_gf.pdf', 4, 1, 2);

-- =============================================================
-- 15. DOCUMENTOS_PORTAFOLIO
-- =============================================================
INSERT INTO documentos_portafolio (ruta, portafolio_id, tipo_documento_id, created_by) VALUES
    ('/uploads/portafolios/2025/port_001_planilla.pdf', 1, 3, 2),
    ('/uploads/portafolios/2025/port_001_guia.pdf',     1, 6, 2),
    ('/uploads/portafolios/2025/port_004_informe.pdf',  4, 4, 5),
    ('/uploads/portafolios/2024/port_005_planilla.pdf', 5, 3, 2);

-- =============================================================
-- Verificación rápida
-- =============================================================
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;
-- SELECT * FROM auditorias ORDER BY id DESC LIMIT 20;
