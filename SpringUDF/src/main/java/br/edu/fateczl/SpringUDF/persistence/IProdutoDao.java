package br.edu.fateczl.SpringUDF.persistence;

import java.sql.SQLException;
import java.util.List;

import br.edu.fateczl.SpringUDF.model.Produto;

public interface IProdutoDao {
	public List<Produto> listaProdutos() throws SQLException, ClassNotFoundException;
	public Produto produtoSituacao(Produto produto) throws SQLException, ClassNotFoundException;
}
