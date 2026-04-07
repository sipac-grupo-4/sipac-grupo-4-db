-- =============================================================
-- SIPAC - Script de Creación de Tablas
-- Base de datos: PostgreSQL
-- =============================================================

-- =============================================================
-- TABLAS DE CATÁLOGO / LOOKUP (sin dependencias externas)
-- =============================================================

CREATE TABLE IF NOT EXISTS roles (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(255) NOT NULL,
    descripcion TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at  TIMESTAMP DEFAULT NULL,
    created_by  INT DEFAULT NULL,
    updated_by  INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS estados (
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP DEFAULT NULL,
    created_by INT DEFAULT NULL,
    updated_by INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS tipos_asignaciones (
    id         SERIAL PRIMARY KEY,
    tipo       VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP DEFAULT NULL,
    created_by INT DEFAULT NULL,
    updated_by INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS tipos_documentos (
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP DEFAULT NULL,
    created_by INT DEFAULT NULL,
    updated_by INT DEFAULT NULL
);

-- =============================================================
-- USUARIOS (depende de roles y estados)
-- =============================================================

CREATE TABLE IF NOT EXISTS usuarios (
    id               SERIAL PRIMARY KEY,
    primer_nombre    VARCHAR(255) NOT NULL,
    segundo_nombre   VARCHAR(255) DEFAULT NULL,
    primer_apellido  VARCHAR(255) NOT NULL,
    segundo_apellido VARCHAR(255) DEFAULT NULL,
    email            VARCHAR(255) NOT NULL UNIQUE,
    contrasena       VARCHAR(255) NOT NULL,
    rol_id           INT NOT NULL,
    estado_id        INT NOT NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at       TIMESTAMP DEFAULT NULL,
    created_by       INT DEFAULT NULL,
    updated_by       INT DEFAULT NULL,
    CONSTRAINT fk_usuarios_rol     FOREIGN KEY (rol_id)    REFERENCES roles(id),
    CONSTRAINT fk_usuarios_estado  FOREIGN KEY (estado_id) REFERENCES estados(id)
);

-- FK diferidas de roles/estados hacia usuarios (auditoría de quién creó/actualizó)
ALTER TABLE roles              ADD CONSTRAINT fk_roles_created_by  FOREIGN KEY (created_by) REFERENCES usuarios(id);
ALTER TABLE roles              ADD CONSTRAINT fk_roles_updated_by  FOREIGN KEY (updated_by) REFERENCES usuarios(id);
ALTER TABLE estados            ADD CONSTRAINT fk_estados_created_by FOREIGN KEY (created_by) REFERENCES usuarios(id);
ALTER TABLE estados            ADD CONSTRAINT fk_estados_updated_by FOREIGN KEY (updated_by) REFERENCES usuarios(id);
ALTER TABLE tipos_asignaciones ADD CONSTRAINT fk_tipos_asig_created_by FOREIGN KEY (created_by) REFERENCES usuarios(id);
ALTER TABLE tipos_asignaciones ADD CONSTRAINT fk_tipos_asig_updated_by FOREIGN KEY (updated_by) REFERENCES usuarios(id);
ALTER TABLE tipos_documentos   ADD CONSTRAINT fk_tipos_doc_created_by  FOREIGN KEY (created_by) REFERENCES usuarios(id);
ALTER TABLE tipos_documentos   ADD CONSTRAINT fk_tipos_doc_updated_by  FOREIGN KEY (updated_by) REFERENCES usuarios(id);

-- =============================================================
-- FICHAS
-- =============================================================

CREATE TABLE IF NOT EXISTS fichas (
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(255) NOT NULL,
    codigo     VARCHAR(255) NOT NULL UNIQUE,
    estado_id  INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP DEFAULT NULL,
    created_by INT DEFAULT NULL,
    updated_by INT DEFAULT NULL,
    CONSTRAINT fk_fichas_estado    FOREIGN KEY (estado_id) REFERENCES estados(id),
    CONSTRAINT fk_fichas_created_by FOREIGN KEY (created_by) REFERENCES usuarios(id),
    CONSTRAINT fk_fichas_updated_by FOREIGN KEY (updated_by) REFERENCES usuarios(id)
);

-- =============================================================
-- FICHAS_INSTRUCTORES (relación muchos a muchos: fichas <-> usuarios)
-- =============================================================

CREATE TABLE IF NOT EXISTS fichas_instructores (
    id              SERIAL PRIMARY KEY,
    fichas_id       INT NOT NULL,
    instructores_id INT NOT NULL,
    CONSTRAINT fk_fi_ficha      FOREIGN KEY (fichas_id)       REFERENCES fichas(id),
    CONSTRAINT fk_fi_instructor FOREIGN KEY (instructores_id) REFERENCES usuarios(id)
);

-- =============================================================
-- PERIODOS
-- =============================================================

CREATE TABLE IF NOT EXISTS periodos (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(255),
    fecha_inicio DATE NOT NULL,
    fecha_fin    DATE NOT NULL,
    estado_id    INT NOT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at   TIMESTAMP DEFAULT NULL,
    created_by   INT DEFAULT NULL,
    updated_by   INT DEFAULT NULL,
    CONSTRAINT fk_periodos_estado     FOREIGN KEY (estado_id) REFERENCES estados(id),
    CONSTRAINT fk_periodos_created_by FOREIGN KEY (created_by) REFERENCES usuarios(id),
    CONSTRAINT fk_periodos_updated_by FOREIGN KEY (updated_by) REFERENCES usuarios(id)
);

-- =============================================================
-- ASIGNACIONES (instructor ↔ ficha con tipo)
-- =============================================================

CREATE TABLE IF NOT EXISTS asignaciones (
    id                 SERIAL PRIMARY KEY,
    usuario_id         INT NOT NULL,
    ficha_id           INT NOT NULL,
    tipo_asignacion_id INT NOT NULL,
    created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at         TIMESTAMP DEFAULT NULL,
    created_by         INT DEFAULT NULL,
    updated_by         INT DEFAULT NULL,
    CONSTRAINT fk_asig_usuario     FOREIGN KEY (usuario_id)         REFERENCES usuarios(id),
    CONSTRAINT fk_asig_ficha       FOREIGN KEY (ficha_id)           REFERENCES fichas(id),
    CONSTRAINT fk_asig_tipo        FOREIGN KEY (tipo_asignacion_id) REFERENCES tipos_asignaciones(id),
    CONSTRAINT fk_asig_created_by  FOREIGN KEY (created_by)         REFERENCES usuarios(id),
    CONSTRAINT fk_asig_updated_by  FOREIGN KEY (updated_by)         REFERENCES usuarios(id)
);

-- =============================================================
-- CUENTAS DE COBRO
-- =============================================================

CREATE TABLE IF NOT EXISTS cuentas_cobro (
    id                SERIAL PRIMARY KEY,
    usuario_id        INT NOT NULL,
    periodo_id        INT NOT NULL,
    estado_id         INT NOT NULL,
    fecha             TIMESTAMP NOT NULL,
    ruta_archivo_gf   VARCHAR(512) DEFAULT NULL,
    ruta_archivo_gc   VARCHAR(512) DEFAULT NULL,
    observaciones     TEXT DEFAULT NULL,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at        TIMESTAMP DEFAULT NULL,
    created_by        INT DEFAULT NULL,
    updated_by        INT DEFAULT NULL,
    CONSTRAINT fk_cc_usuario    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_cc_periodo    FOREIGN KEY (periodo_id) REFERENCES periodos(id),
    CONSTRAINT fk_cc_estado     FOREIGN KEY (estado_id)  REFERENCES estados(id),
    CONSTRAINT fk_cc_created_by FOREIGN KEY (created_by) REFERENCES usuarios(id),
    CONSTRAINT fk_cc_updated_by FOREIGN KEY (updated_by) REFERENCES usuarios(id)
);

-- =============================================================
-- PORTAFOLIOS
-- =============================================================

CREATE TABLE IF NOT EXISTS portafolios (
    id         SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    ficha_id   INT NOT NULL,
    periodo_id INT NOT NULL,
    estado_id  INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP DEFAULT NULL,
    created_by INT DEFAULT NULL,
    updated_by INT DEFAULT NULL,
    CONSTRAINT fk_port_usuario    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_port_ficha      FOREIGN KEY (ficha_id)   REFERENCES fichas(id),
    CONSTRAINT fk_port_periodo    FOREIGN KEY (periodo_id) REFERENCES periodos(id),
    CONSTRAINT fk_port_estado     FOREIGN KEY (estado_id)  REFERENCES estados(id),
    CONSTRAINT fk_port_created_by FOREIGN KEY (created_by) REFERENCES usuarios(id),
    CONSTRAINT fk_port_updated_by FOREIGN KEY (updated_by) REFERENCES usuarios(id)
);

-- =============================================================
-- FECHAS LÍMITE
-- =============================================================

CREATE TABLE IF NOT EXISTS fechas_limite (
    id               SERIAL PRIMARY KEY,
    periodo_id       INT NOT NULL,
    tipo_documento_id INT NOT NULL,
    fecha            TIMESTAMP NOT NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at       TIMESTAMP DEFAULT NULL,
    created_by       INT DEFAULT NULL,
    updated_by       INT DEFAULT NULL,
    CONSTRAINT fk_fl_periodo      FOREIGN KEY (periodo_id)        REFERENCES periodos(id),
    CONSTRAINT fk_fl_tipo_doc     FOREIGN KEY (tipo_documento_id) REFERENCES tipos_documentos(id),
    CONSTRAINT fk_fl_created_by   FOREIGN KEY (created_by)        REFERENCES usuarios(id),
    CONSTRAINT fk_fl_updated_by   FOREIGN KEY (updated_by)        REFERENCES usuarios(id)
);

-- =============================================================
-- NOTIFICACIONES
-- =============================================================

CREATE TABLE IF NOT EXISTS notificaciones (
    id         SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    mensaje    TEXT,
    fecha      TIMESTAMP DEFAULT NULL,
    leida      SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP DEFAULT NULL,
    created_by INT DEFAULT NULL,
    updated_by INT DEFAULT NULL,
    CONSTRAINT fk_notif_usuario    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_notif_created_by FOREIGN KEY (created_by) REFERENCES usuarios(id),
    CONSTRAINT fk_notif_updated_by FOREIGN KEY (updated_by) REFERENCES usuarios(id)
);

-- =============================================================
-- DOCUMENTOS_CUENTA_COBRO
-- =============================================================

CREATE TABLE IF NOT EXISTS documentos_cuenta_cobro (
    id               SERIAL PRIMARY KEY,
    ruta             VARCHAR(512) NOT NULL,
    cuenta_cobro_id  INT NOT NULL,
    tipo_documento_id INT NOT NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at       TIMESTAMP DEFAULT NULL,
    created_by       INT DEFAULT NULL,
    updated_by       INT DEFAULT NULL,
    CONSTRAINT fk_dcc_cuenta      FOREIGN KEY (cuenta_cobro_id)   REFERENCES cuentas_cobro(id),
    CONSTRAINT fk_dcc_tipo_doc    FOREIGN KEY (tipo_documento_id) REFERENCES tipos_documentos(id),
    CONSTRAINT fk_dcc_created_by  FOREIGN KEY (created_by)        REFERENCES usuarios(id),
    CONSTRAINT fk_dcc_updated_by  FOREIGN KEY (updated_by)        REFERENCES usuarios(id)
);

-- =============================================================
-- DOCUMENTOS_PORTAFOLIO
-- =============================================================

CREATE TABLE IF NOT EXISTS documentos_portafolio (
    id               SERIAL PRIMARY KEY,
    ruta             VARCHAR(512) NOT NULL,
    portafolio_id    INT NOT NULL,
    tipo_documento_id INT NOT NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at       TIMESTAMP DEFAULT NULL,
    created_by       INT DEFAULT NULL,
    updated_by       INT DEFAULT NULL,
    CONSTRAINT fk_dp_portafolio   FOREIGN KEY (portafolio_id)     REFERENCES portafolios(id),
    CONSTRAINT fk_dp_tipo_doc     FOREIGN KEY (tipo_documento_id) REFERENCES tipos_documentos(id),
    CONSTRAINT fk_dp_created_by   FOREIGN KEY (created_by)        REFERENCES usuarios(id),
    CONSTRAINT fk_dp_updated_by   FOREIGN KEY (updated_by)        REFERENCES usuarios(id)
);

-- =============================================================
-- AUDITORÍAS (generadas por triggers, no por el backend directo)
-- =============================================================

CREATE TABLE IF NOT EXISTS auditorias (
    id               SERIAL PRIMARY KEY,
    usuario_id       INT DEFAULT NULL,          -- NULL si la acción es del sistema
    accion           VARCHAR(255) NOT NULL,      -- INSERT / UPDATE / DELETE
    entidad_afectada VARCHAR(255) NOT NULL,      -- nombre de la tabla
    valor_anterior   TEXT DEFAULT NULL,
    valor_nuevo      TEXT DEFAULT NULL,
    fecha            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at       TIMESTAMP DEFAULT NULL,
    created_by       INT DEFAULT NULL,
    updated_by       INT DEFAULT NULL,
    CONSTRAINT fk_aud_usuario    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_aud_created_by FOREIGN KEY (created_by) REFERENCES usuarios(id),
    CONSTRAINT fk_aud_updated_by FOREIGN KEY (updated_by) REFERENCES usuarios(id)
);

-- =============================================================
-- FUNCIÓN GENÉRICA DE AUDITORÍA
-- Se llama desde todos los triggers de auditoría
-- Usa current_setting para recibir el usuario activo de la sesión
-- =============================================================

CREATE OR REPLACE FUNCTION fn_auditoria()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_usuario_id  INT;
    v_anterior    TEXT;
    v_nuevo       TEXT;
    v_accion      VARCHAR(50);
BEGIN
    -- El backend debe ejecutar: SET LOCAL sipac.usuario_id = <id>;
    BEGIN
        v_usuario_id := current_setting('sipac.usuario_id')::INT;
    EXCEPTION WHEN OTHERS THEN
        v_usuario_id := NULL;
    END;

    IF (TG_OP = 'DELETE') THEN
        v_accion    := 'DELETE';
        v_anterior  := row_to_json(OLD)::TEXT;
        v_nuevo     := NULL;
    ELSIF (TG_OP = 'UPDATE') THEN
        v_accion    := 'UPDATE';
        v_anterior  := row_to_json(OLD)::TEXT;
        v_nuevo     := row_to_json(NEW)::TEXT;
    ELSIF (TG_OP = 'INSERT') THEN
        v_accion    := 'INSERT';
        v_anterior  := NULL;
        v_nuevo     := row_to_json(NEW)::TEXT;
    END IF;

    INSERT INTO auditorias (usuario_id, accion, entidad_afectada, valor_anterior, valor_nuevo, fecha)
    VALUES (v_usuario_id, v_accion, TG_TABLE_NAME, v_anterior, v_nuevo, NOW());

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

-- =============================================================
-- TRIGGERS DE AUDITORÍA (una función, todos los disparadores)
-- =============================================================

-- usuarios
CREATE TRIGGER trg_aud_usuarios
AFTER INSERT OR UPDATE OR DELETE ON usuarios
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- roles
CREATE TRIGGER trg_aud_roles
AFTER INSERT OR UPDATE OR DELETE ON roles
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- estados
CREATE TRIGGER trg_aud_estados
AFTER INSERT OR UPDATE OR DELETE ON estados
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- fichas
CREATE TRIGGER trg_aud_fichas
AFTER INSERT OR UPDATE OR DELETE ON fichas
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- periodos
CREATE TRIGGER trg_aud_periodos
AFTER INSERT OR UPDATE OR DELETE ON periodos
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- asignaciones
CREATE TRIGGER trg_aud_asignaciones
AFTER INSERT OR UPDATE OR DELETE ON asignaciones
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- cuentas_cobro
CREATE TRIGGER trg_aud_cuentas_cobro
AFTER INSERT OR UPDATE OR DELETE ON cuentas_cobro
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- portafolios
CREATE TRIGGER trg_aud_portafolios
AFTER INSERT OR UPDATE OR DELETE ON portafolios
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- fechas_limite
CREATE TRIGGER trg_aud_fechas_limite
AFTER INSERT OR UPDATE OR DELETE ON fechas_limite
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- notificaciones
CREATE TRIGGER trg_aud_notificaciones
AFTER INSERT OR UPDATE OR DELETE ON notificaciones
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- documentos_cuenta_cobro
CREATE TRIGGER trg_aud_documentos_cuenta_cobro
AFTER INSERT OR UPDATE OR DELETE ON documentos_cuenta_cobro
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- documentos_portafolio
CREATE TRIGGER trg_aud_documentos_portafolio
AFTER INSERT OR UPDATE OR DELETE ON documentos_portafolio
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- tipos_asignaciones
CREATE TRIGGER trg_aud_tipos_asignaciones
AFTER INSERT OR UPDATE OR DELETE ON tipos_asignaciones
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- tipos_documentos
CREATE TRIGGER trg_aud_tipos_documentos
AFTER INSERT OR UPDATE OR DELETE ON tipos_documentos
FOR EACH ROW EXECUTE FUNCTION fn_auditoria();
