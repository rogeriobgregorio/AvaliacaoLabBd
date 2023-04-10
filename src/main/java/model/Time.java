package model;

public class Time {

	private int codigoTime;
	private String nomeTime;
	private String cidade;
	private String estadio;
	private String materialEsportivo;

	public Time() {
	}

	public Time(int codigoTime, String nomeTime, String cidade, String estadio, String materialEsportivo) {
		super();
		this.codigoTime = codigoTime;
		this.nomeTime = nomeTime;
		this.cidade = cidade;
		this.estadio = estadio;
		this.materialEsportivo = materialEsportivo;
	}

	public int getCodigoTime() {
		return codigoTime;
	}

	public void setCodigoTime(int codigoTime) {
		this.codigoTime = codigoTime;
	}

	public String getNomeTime() {
		return nomeTime;
	}

	public void setNomeTime(String nomeTime) {
		this.nomeTime = nomeTime;
	}

	public String getCidade() {
		return cidade;
	}

	public void setCidade(String cidade) {
		this.cidade = cidade;
	}

	public String getEstadio() {
		return estadio;
	}

	public void setEstadio(String estadio) {
		this.estadio = estadio;
	}

	public String getMaterialEsportivo() {
		return materialEsportivo;
	}

	public void setMaterialEsportivo(String materialEsportivo) {
		this.materialEsportivo = materialEsportivo;
	}

	@Override
	public String toString() {
		return "Time [codigoTime=" + codigoTime + ", nomeTime=" + nomeTime + ", cidade=" + cidade + ", estadio="
				+ estadio + ", materialEsportivo=" + materialEsportivo + "]";
	}

}
