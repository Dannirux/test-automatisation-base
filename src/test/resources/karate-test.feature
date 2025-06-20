@REQ_TEST-Q2 @HUQ2 @marvel_characters_api @marvel_characters @Agente2 @E2 @TEST-Q2_api_characters_marvel
Feature: TEST-Q2 Gestión de personajes de Marvel (microservicio para administrar información de personajes)

  Background:
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser'
    * def pathCharacters = '/api/characters'
    * path pathCharacters
    * def generarHeaders =
      """
      function() {
        return {
          "Content-Type": "application/json"
        };
      }
      """
    * def wait =
      """
      function(ms) {
        java.lang.Thread.sleep(ms);
      }
      """
    * def headers = generarHeaders()
    * def timestamp = java.lang.String.valueOf(java.lang.System.currentTimeMillis())
    * def random = java.lang.String.valueOf(java.lang.Math.floor(100000000 + Math.random() * 900000000)).replace('.0','')
    * def pathInvalid = random
    * headers headers

  @id:1 @obtenerPersonajes @solicitudExitosa200
  Scenario: T-API-TEST-Q2-CA01-Obtener todos los personajes 200 - karate
    When method GET
    Then status 200
    And match response != null
    And match response == '#[]'
    * def ids = []
    * eval for (var i = 0; i < response.length; i++) ids.push(response[i].id)
    * match ids == karate.distinct(ids)


  @id:2 @crearPersonaje @solicitudExitosa201
  Scenario: T-API-TEST-Q2-CA02-Crear personaje exitosamente 201 - karate
    * def jsonData = read('classpath:data/marvel_characters/characters_data.json')[0]
    * jsonData.name = jsonData.name + ' ' + timestamp
    And request jsonData
    When method POST
    Then status 201
    And match response.id != null
    And match response.alterego == jsonData.alterego
    And match response.description == jsonData.description
    And match response.powers == jsonData.powers

  @id:3 @crearPersonaje @errorValidacion400
  Scenario: T-API-TEST-Q2-CA03-Crear personaje con datos inválidos 400 - karate
    * def jsonData = read('classpath:data/marvel_characters/request_fields_invalid.json')
    And request jsonData
    When method POST
    Then status 400
    And match response != null
    And match response.name contains 'required'
    And match response.alterego contains 'required'
    And match response.description contains 'required'
    And match response.powers contains 'required'

  @id:4 @crearPersonaje @errorDuplicado400
  Scenario: T-API-TEST-Q2-CA04-Crear personaje con nombre duplicado 400 - karate
    * def jsonData = read('classpath:data/marvel_characters/request_create_character.json')
    * jsonData.name = jsonData.name + ' ' + timestamp
    And request jsonData
    When method POST
    Then status 201
    * wait(1000)
    * path pathCharacters
    And request jsonData
    When method POST
    Then status 400
    And match response != null
    And match response.error == 'Character name already exists'
    And match response == { "error": "#string" }

  @id:5 @obtenerPersonajePorId @solicitudExitosa200
  Scenario: T-API-TEST-Q2-CA05-Obtener personaje por ID 200 - karate
    * def jsonData = read('classpath:data/marvel_characters/characters_data.json')[1]
    * jsonData.name = jsonData.name + ' ' + timestamp
    And request jsonData
    When method POST
    Then status 201
    * def characterId = response.id
    * wait(1000)
    * path pathCharacters, characterId
    When method GET
    Then status 200
    And match response.id == characterId
    And match response.name == jsonData.name
    And match response.alterego == jsonData.alterego
    And match response.description == jsonData.description
    And match response.powers == jsonData.powers

  @id:6 @obtenerPersonajePorId @errorNoEncontrado404
  Scenario: T-API-TEST-Q2-CA06-Obtener personaje con ID inexistente 404 - karate
    * path pathInvalid
    When method GET
    Then status 404
    And match response != null
    And match response.error == 'Character not found'
    And match response == { "error": "#string" }

  @id:7 @actualizarPersonaje @solicitudExitosa200
  Scenario: T-API-TEST-Q2-CA07-Actualizar personaje exitosamente 200 - karate
    * def jsonData = read('classpath:data/marvel_characters/characters_data.json')[2]
    * jsonData.name = jsonData.name + ' ' + timestamp
    And request jsonData
    When method POST
    Then status 201
    * def characterId = response.id
    * wait(1000)
    * path pathCharacters, characterId
    * set jsonData.description = 'Updated description for testing'
    And request jsonData
    When method PUT
    Then status 200
    And match response.id == characterId
    And match response.description == 'Updated description for testing'
    And match response.name == jsonData.name
    And match response.alterego == jsonData.alterego
    And match response.powers == jsonData.powers

  @id:8 @actualizarPersonaje @errorNoEncontrado404
  Scenario: T-API-TEST-Q2-CA08-Actualizar personaje con ID inexistente 404 - karate
    * def jsonData = read('classpath:data/marvel_characters/characters_data.json')[0]
    * path pathInvalid
    And request jsonData
    When method PUT
    Then status 404
    And match response != null
    And match response.error == 'Character not found'
    And match response == { "error": "#string" }

  @id:9 @eliminarPersonaje @solicitudExitosa204
  Scenario: T-API-TEST-Q2-CA09-Eliminar personaje exitosamente 204 - karate
    * def jsonData = read('classpath:data/marvel_characters/characters_data.json')[0]
    * jsonData.name = jsonData.name + ' ' + timestamp
    And request jsonData
    When method POST
    Then status 201
    * def characterId = response.id
    * wait(1000)
    * path pathCharacters, characterId
    When method DELETE
    Then status 204

  @id:10 @eliminarPersonaje @errorNoEncontrado404
  Scenario: T-API-TEST-Q2-CA10-Eliminar personaje con ID inexistente 404 - karate
    * path pathInvalid
    When method DELETE
    Then status 404
    And match response != null
    And match response.error == 'Character not found'
    And match response == { "error": "#string" }
