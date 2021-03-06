using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TVBlueprint : MonoBehaviour
{
    RaycastHit hit;
    Vector3 movePoint;
    private bool canBuild;
    Vector3 auxVector;
    Vector3 secondAuxVector;
    public TVCraftingRecipe craftingRecipe;
    public GameObject trapAnimPrefab;
    public GameObject particles;
    public GameObject customPivot;
    [SerializeField]
    private Material newMaterial;
    private Material originalMaterial;
    private Renderer myRenderer;
    private Vector3 finalPosition;
    private Quaternion finalRotation;
    private Renderer[] _myChildrenRenderers;

    void Start()
    {
        canBuild = true;
        //originalMaterial = GetComponent<Renderer>().material; //Probar despues de arreglar posicionamiento. 
        originalMaterial = GetComponentInChildren<Renderer>().material;
        //myRenderer = GetComponent<Renderer>(); //Probar despues de arreglar posicionamiento.
        _myChildrenRenderers = GetComponentsInChildren<Renderer>();  
    }

    void Update()
    {
        //Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        

        //Canbuild provisional.

        if(Physics.Raycast(GameVars.Values.GetPlayerCameraPosition(), GameVars.Values.GetPlayerCameraForward(), out hit, 100f, GameVars.Values.GetFloorLayerMask()) && canBuild)
        {
            auxVector = new Vector3(hit.point.x, 2.8f, hit.point.z);
            transform.position = auxVector;
            //transform.position = hit.point;
        }

        if(Input.GetKeyDown(GameVars.Values.primaryFire) && canBuild)
        {
            secondAuxVector = new Vector3(transform.position.x, 2.8f, transform.position.z);
            finalPosition = secondAuxVector;
            //finalPosition = transform.position;
            finalRotation = transform.rotation;
            StartCoroutine(BuildTrap());

            /* Instantiate(particles, transform.position, transform.rotation);
            GameObject aux = Instantiate(trapAnimPrefab, transform.position, transform.rotation);
            //Destroy(aux.GetComponent<InventoryItem>());
            craftingRecipe.RemoveItems();
            craftingRecipe.RestoreBuildAmount();
            Destroy(gameObject); */
        }

        if(Input.GetKeyDown(GameVars.Values.secondaryFire))
        {
            Destroy(gameObject);
            craftingRecipe.RestoreBuildAmount();
        }

        if (Input.GetAxis("Mouse ScrollWheel") > 0) 
        {
        transform.Rotate(Vector3.forward * -15f, Space.Self);
        }

        if (Input.GetAxis("Mouse ScrollWheel") < 0) 
        {
        transform.Rotate(Vector3.forward * 15f, Space.Self);
        }
    }

    private IEnumerator BuildTrap()
    {
        Instantiate(particles, transform.position, transform.rotation);
        //myRenderer.enabled = false; //Probar despues de arreglar posicionamiento. 

        foreach(Renderer r in _myChildrenRenderers)
        r.enabled = false;

        //Canbuild provisional.
        canBuild = false;
        GameVars.Values.soundManager.PlaySoundAtPoint("TrapConstructionSnd", transform.position, 0.9f);
        yield return new WaitForSeconds(2f);
        GameObject aux = Instantiate(trapAnimPrefab, finalPosition, finalRotation);
        //Destroy(aux.GetComponent<InventoryItem>());
        craftingRecipe.RemoveItems();
        craftingRecipe.RestoreBuildAmount();
        Destroy(gameObject);
        
    }

    private void ChangeMaterial()
    {
        //Renderer[] rs = GetComponentsInChildren<Renderer>();
        foreach(Renderer r in _myChildrenRenderers)
        r.material = newMaterial;

        //myRenderer.material = newMaterial; //Probar despues de arreglar posicionamiento.
    }

    private void SetOriginalMaterial()
    {
        //Renderer[] rs = GetComponentsInChildren<Renderer>();
        foreach(Renderer r in _myChildrenRenderers)
        r.material = originalMaterial;

        //myRenderer.material = originalMaterial; //Probar despues de arreglar posicionamiento.
    }

    void OnTriggerStay(Collider other)
    {
        canBuild = false;
        ChangeMaterial();
    }

    void OnTriggerExit(Collider other)
    {
        canBuild = true;
        SetOriginalMaterial();
    }
}