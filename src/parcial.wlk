class Lugar {
	const senderos = []
	
	method conectaCon(destino) =
		senderos.any { camino => camino.llevaA(destino) }
	
	method cuantoTardariaEnLlegarA(destino, persona) {
		const sendero = self.caminoHacia(destino)
		return sendero.tiempoEnRecorrersePor(persona)
	}
	
	method caminoHacia(destino) {
		self.validarQueSePuedeLlegarA(destino)
		return senderos.find { camino => camino.llevaA(destino) }
	}
	
	method destinoMasCercanoDe(persona) =
		senderos.min { camino => camino.tiempoEnRecorrersePor(persona) }.destino()
	
	method validarQueSePuedeLlegarA(destino) {
		if(!self.conectaCon(destino)) {
			self.error("No se puede llegar a " + destino)
		}
	}
}

class Sendero {
	const property destino
	const longitud
	method llevaA(unDestino) = unDestino == destino
	method tiempoEnRecorrersePor(persona) =
		longitud / self.velocidadDe(persona)
	method velocidadDe(persona)
}

class SenderoUrbano inherits Sendero {
	const indiceDeTrafico
	override method tiempoEnRecorrersePor(persona) =
		super(persona) * indiceDeTrafico
	method velocidadDe(persona) = persona.velocidad()
}

class SenderoRural inherits Sendero {
	method velocidadDe(persona) = persona.velocidadACampoAbierto()
}

class Habitante {
	var property lugar
	var dedicacion
	var horasTrabajadas = 0
	var tareasRealizadas = 0

	method velocidad()
	method velocidadACampoAbierto() = self.velocidad()
	method tieneTiempoParaHacerla(duracionDeLaTarea) =
		duracionDeLaTarea < self.horasRestantes()
	method aumentarHorasTrabajadas(duracion) {
		horasTrabajadas += duracion
	}
	method ganarHoras(cantidad) {
		dedicacion += cantidad
	}
	method horasRestantes() = dedicacion - horasTrabajadas
	
	method puedeLlegarA(destino) = lugar.conectaCon(destino)
	
	method cuantoTardariaEnLlegarA(destino) = lugar.cuantoTardariaEnLlegarA(destino, self)
	
	method destinoMasCercano() = lugar.destinoMasCercanoDe(self)
	
	method registrarTareaRealizada(tarea) {
		horasTrabajadas += tarea.duracionPara(self)
		tareasRealizadas += 1
	}
	
	method realizarItinerario(tareas) {
		tareas.forEach { tarea => 
			tarea.serRealizadaPor(self)
		}
	}
	
	method cantidadDeTareasCompletas() = tareasRealizadas
}

const casaDeJim = new Lugar()
const casaDeAja = new Lugar()
const casaDeClara = new Lugar()

object jim inherits Habitante(lugar = casaDeJim, dedicacion = 7) {
	override method velocidad() = 90
	override method velocidadACampoAbierto() = 9
}

object clara inherits Habitante(lugar = casaDeClara, dedicacion = 7) {
	override method velocidad() = 10
}

object aja inherits Habitante(lugar = casaDeAja, dedicacion = 5) {
	override method velocidad() = 12
}

object pendiente {}
object completada {}
object fallida {}

class Tarea {
	
	method serRealizadaPor(habitante) {
		if(self.puedeSerRealizada(habitante)) {
			habitante.registrarTareaRealizada(self)
			self.realizarse(habitante)			
		}
	}
	
	method puedeSerRealizada(habitante) =
		self.sePuedeHacer(habitante) && habitante.tieneTiempoParaHacerla(self.duracionPara(habitante))
	
	method realizarse(habitante)
	
	method duracionPara(habitante)
	
	method sePuedeHacer(habitante) 
}

class Moverse inherits Tarea {
	override method sePuedeHacer(habitante) =
		habitante.puedeLlegarA(self.destino(habitante))
	
	override method duracionPara(habitante) =
		habitante.cuantoTardariaEnLlegarA(self.destino(habitante))
		
	override method realizarse(habitante) =
		habitante.lugar(self.destino(habitante))
		
	method destino(habitante)
}

class MoverseAUnDestino inherits Moverse {
	const destino
	
	override method destino(habitante) = destino
}

class MoverseAlDestinoMasCercano inherits Moverse {
	override method destino(habitante) = habitante.destinoMasCercano()
}

class UsarInstrumentoMagico inherits Tarea {
	const habitanteObjetivo
	const instrumentoMagico
	
	override method sePuedeHacer(habitante) =
		habitante.lugar() == habitanteObjetivo.lugar()
		
	override method realizarse(habitante) =
		instrumentoMagico.usarseEn(habitante)
		
	override method duracionPara(habitante) =
		instrumentoMagico.duracionPara(habitante)
}

class Kairosecto {
	method duracionPara(habitante) = 1
	method usarseEn(habitante) {
		habitante.ganarHoras(3)
	}
		
}

class BaculoDeSombras {
	const destino
	
	method usarseEn(habitante) {
		habitante.lugar(destino)
	}
	
	method duracionPara(habitante) = habitante.horasRestantes() / 2
}

object alcaldia {
	method realizarTareas(itinerario, habitantes) {
		habitantes.forEach { habitante =>
			habitante.realizarItinerario(itinerario)
		}
	}
	
	method habitanteMasEficaz(habitantes) =
		habitantes.max { habitante => habitante.cantidadDeTareasCompletas() }
}
