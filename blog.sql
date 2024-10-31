-- Criação do banco de dados
CREATE DATABASE BlogFórum;
USE BlogFórum;

-- Tabela para armazenar informações dos usuários
CREATE TABLE Usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (email)
);

-- Tabela para armazenar posts
CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    conteudo TEXT NOT NULL,
    data_postagem DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE
);

-- Tabela para armazenar comentários
CREATE TABLE Comentarios (
    comentario_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    usuario_id INT NOT NULL,
    conteudo TEXT NOT NULL,
    data_comentario DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE
);

-- Índices para melhorar a performance
CREATE INDEX idx_usuario_email ON Usuarios(email);
CREATE INDEX idx_post_usuario ON Posts(usuario_id);
CREATE INDEX idx_comentario_post ON Comentarios(post_id);

-- View para mostrar posts com os autores
CREATE VIEW ViewPosts AS
SELECT p.post_id, p.titulo, p.conteudo, p.data_postagem, u.nome AS autor
FROM Posts p
JOIN Usuarios u ON p.usuario_id = u.usuario_id;

-- Função para contar comentários por post
DELIMITER //
CREATE FUNCTION ContarComentarios(postId INT) RETURNS INT
BEGIN
    DECLARE qtd INT;
    SELECT COUNT(*) INTO qtd FROM Comentarios WHERE post_id = postId;
    RETURN qtd;
END //
DELIMITER ;

-- Trigger para atualizar a contagem de comentários
DELIMITER //
CREATE TRIGGER Trigger_AposInserirComentario
AFTER INSERT ON Comentarios
FOR EACH ROW
BEGIN
    UPDATE Posts SET conteudo = CONCAT(conteudo, ' [Comentários: ', ContarComentarios(NEW.post_id), ']')
    WHERE post_id = NEW.post_id;
END //
DELIMITER ;

-- Inserção de exemplo de usuários
INSERT INTO Usuarios (nome, email, senha) VALUES 
('João Silva', 'joao@example.com', 'senha1'),
('Maria Souza', 'maria@example.com', 'senha2');

-- Inserção de exemplo de posts
INSERT INTO Posts (usuario_id, titulo, conteudo) VALUES 
(1, 'Meu Primeiro Post', 'Conteúdo do primeiro post.'),
(2, 'Dicas de Programação', 'Conteúdo sobre programação.');

-- Inserção de exemplo de comentários
INSERT INTO Comentarios (post_id, usuario_id, conteudo) VALUES 
(1, 2, 'Muito bom o post!'),
(1, 1, 'Obrigado pela visita!'),
(2, 1, 'Ótimas dicas, vou testar!');

-- Selecionar todos os posts com autores
SELECT * FROM ViewPosts;

-- Selecionar todos os comentários de um post específico
SELECT * FROM Comentarios WHERE post_id = 1;
