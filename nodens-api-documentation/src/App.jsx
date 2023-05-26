import SwaggerUI from "swagger-ui-react"
import "swagger-ui-react/swagger-ui.css"
import Nodens_Documentation from "./assets/nodens-api.json"

function App() {
  console.log(Nodens_Documentation);
  return (
    <SwaggerUI spec={Nodens_Documentation} />
  )
}

export default App
