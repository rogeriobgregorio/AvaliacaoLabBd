package model;

public class Grupo {

	private String grupo;
	private Time time;

	public Grupo() {
	}

	public String getGrupo() {
		return grupo;
	}

	public void setGrupo(String grupo) {
		this.grupo = grupo;
	}

	public Time getTime() {
		return time;
	}

	public void setTime(Time time) {
		this.time = time;
	}

	@Override
	public String toString() {
		return "Grupo [grupo=" + grupo + ", time=" + time + "]";
	}
}
