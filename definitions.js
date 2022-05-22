function filter_names(e){
  return (e.start['@id'].startsWith("/c/en") || e.start['@id'].startsWith('/c/fr'))
         && (e.end['@id'].startsWith("/c/en") || e.end['@id'].startsWith('/c/fr'))
}

function remove_names(e){
  console.log(e['edges'].filter(filter_names))
   return e['edges'].filter(filter_names);
}

// see https://github.com/commonsense/conceptnet5/wiki/API#complex-queries for reference
function query_concept(query){


  let headers = new Headers();
  headers.append('Content-type', "application/json")

  const options = {
    method : "GET",
    headers : headers
  }


  console.log(query)
  let returnVal = undefined;

  if (typeof query === 'string'){
    returnVal = fetch('https://api.conceptnet.io' + query, options).then(r => r.json());
  }
  else if (typeof query === "object"){

    validKeywords = ['start', 'end', 'rel', 'node', 'other', 'source', 'limit', 'offset', 'filter']

    for (const entry of Object.entries(query)){
      key = entry[0]

      if (!validKeywords.includes(key)){
        throw new Error("Invalid keyword in concept query. Only " + validKeywords + " are accepted (" + key+ " invalid)")
      }
    }

    let params = new URLSearchParams(query)
    returnVal = fetch('https://api.conceptnet.io/query?' + params, options).then(r => r.json());
  }
  else{
    throw new Error("Argument must be of type string or Object")
  }



  return returnVal.then(r => {
    r.nextPage = function() {
      return query_concept(r['view']['nextPage'])
    }

    r.firstPage = function() {
      return query_concept(r['view']['firstPage'])
    }
    r.previousPage = function() {
      return query_concept(r['view']['previousPage'])
    }

    return r

  })
}


// Cache des faits
_cent_faits = undefined
/*
 *   A l’issue de cette  ́etape, vous disposerez d’au moins 100 faits que vous
encoderez sous forme d’une table HTML. Cette structure sera utilis ́ee
par d ́efaut pour alimenter les questions pos ́ees dans les jeux. Prenez
note que votre table doit r ́eunir au moins 40 concepts diff ́erents (start
ou end) et au moins 20 relations diff ́erentes.
 *
 */

function get_100_faits(){
  // limite de 40 concepts
  //let all_edges = await query_concept({limit:100})
  wanted_relations = [
    "/r/RelatedTo",
    "/r/FormOf",
    "/r/IsA",
    "/r/PartOf",
    "/r/HasA",
    "/r/UsedFor",
    "/r/CapableOf",
    "/r/AtLocation",
    "/r/Causes",
    "/r/HasSubevent",
    "/r/HasFirstSubevent",
    "/r/HasLastSubevent",
    "/r/HasPrerequisite",
    "/r/HasProperty",
    "/r/MotivatedByGoal",
    "/r/ObstructedBy",
    "/r/Desires",
    "/r/CreatedBy",
    "/r/Synonym",
    "/r/Antonym",
    "/r/DistinctFrom",
    // "/r/DerivedFrom",
    // "/r/SymbolOf",
    // "/r/DefinedAs",
    // "/r/MannerOf",
    // "/r/LocatedNear",
    // "/r/HasContext",
    // "/r/SimilarTo",
    // "/r/EtymologicallyRelatedTo",
    // "/r/EtymologicallyDerivedFrom",
    // "/r/CausesDesire",
    // "/r/MadeOf",
    // "/r/ReceivesAction",
    // "/r/ExternalURL"
  ]

  return fetch("./cached-100-facts").then(r => {

    if (r.status == 200){
      return r.json()
    }else {
      return Promise.all(wanted_relations.map((e, i) => query_concept({limit:5, rel:e, node:'/c/en'})))
                    .then(query_result => {
                      let result = [].concat(...query_result.map(x => x.edges));
                      console.log("Could not find cached version on server, result of this request : ", result);
                      return result
                    })
    }
  })


  // console.log(all_edges)
  // to_keep = []
  // not_important = []
  // relation_min = 20 // TODO : Change this
  // concept_min = 40

  // let i = 0;
  // let concepts = new Set()
  // let relations = new Set()

  // while (concepts.size < concept_min || relations.size < relation_min){
  //   for (const edge of all_edges['edges']){
  //     let rel_id = edge['rel']['@id']
  //     let start_id = edge['start']['@id']
  //     let end_id = edge['end']['@id']

  //     if ((!relations.has(rel_id) && relations.size < relation_min)
  //         || ((!concepts.has(start_id) || !concepts.has(end_id)) && concepts.size < concept_min)){
  //       to_keep.push(edge)
  //     }
  //     else{
  //       not_important.push(edge)
  //     }

  //     concepts.add(start_id)
  //     concepts.add(end_id)
  //     relations.add(rel_id)
  //   }
  //   console.log(concepts.size, relations.size)
  //   all_edges = await all_edges.nextPage()
  // }

  // const to_keep_length = to_keep.length
  // for (let i = 0; i < 100 - to_keep_length; i++){
  //   to_keep.push(not_important[i])
  // }

  // return to_keep
}

function htmlElement(type, modifs = (x => x)){
  return function(...content){
    let elem = document.createElement(type)
    modifs(elem)
    for (let c of content){
      if(typeof c === "string"){
        node = document.createTextNode(content)
        elem.appendChild(node)
      }
      else if(c instanceof HTMLElement){
        elem.appendChild(c)
      }
      else{
        console.err("cannot find element")
      }
    }

    return elem
  }
}

function button(name, callback){
  let btn = document.createElement("button");
  btn.onclick = callback
  btn.innerHTML = name;
  return btn
}

let tr = htmlElement('tr')
let th = htmlElement('th')
let table = htmlElement('table', x => {x.classList.add("table")})
let tbody = htmlElement('tbody')
let thead = htmlElement('thead')
let div = htmlElement("div")
let h1 = htmlElement("h1")



function display(name){
  document.body.appendChild(htmlMenu())
  document.body.appendChild(htmlTable())

}


function htmlTable(){
  get_100_faits().then(faits => {
    document.querySelector(".loading").style.display = 'none'
    document.body.appendChild(
      table(
        thead(
          tr(th("Start"), th("Relation"), th("End"))
        ),
        tbody(...faits.map(f => tr(th(f['start']['label']),
                                   th(f['rel']['label']),
                                   th(f['end']['label']))))))
  })
}

//document.body.appendChild(htmlMenu())
