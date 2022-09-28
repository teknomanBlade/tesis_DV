using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blueprint : MonoBehaviour
{
    private Player _player;
    RaycastHit hit;
    Vector3 movePoint;
    private bool canBuild;
    Vector3 auxVector;
    Vector3 secondAuxVector;
    public CraftingRecipe craftingRecipe;
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
    public LayerMask LayerMaskWall;
    int layerMask;
    private GameObject parent;  

    void Start()
    {
        parent = GameObject.Find("MainGame");
        _player = GameObject.Find("Player").GetComponent<Player>();
        int layerMask = GameVars.Values.GetWallLayer();
        layerMask = ~layerMask;
        canBuild = true;
        //originalMaterial = GetComponent<Renderer>().material; //Probar despues de arreglar posicionamiento. 
        originalMaterial = GetComponentInChildren<Renderer>().material;
        //myRenderer = GetComponent<Renderer>(); //Probar despues de arreglar posicionamiento.
        _myChildrenRenderers = GetComponentsInChildren<Renderer>();

    }

    void Update()
    {
        //Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        if (Physics.Raycast(GameVars.Values.GetPlayerCameraPosition(), GameVars.Values.GetPlayerCameraForward(), out hit, 100f, LayerMaskWall))
        {
            Debug.DrawRay(transform.position, transform.TransformDirection(Vector3.forward) * hit.distance, Color.yellow);
            Debug.Log("Blue print Hit " + hit.collider.gameObject.layer + " " + hit.collider.gameObject.name);
            canBuild = false;
            transform.position = hit.point;
            ChangeMaterial();
            return;
        }
        else
        {
            canBuild = true;
            SetOriginalMaterial();
        }


        if (Physics.Raycast(GameVars.Values.GetPlayerCameraPosition(), GameVars.Values.GetPlayerCameraForward(), out hit, 100f, GameVars.Values.GetFloorLayerMask()) && canBuild)
        {
            //auxVector = new Vector3(hit.point.x, 1f, hit.point.z);
            //transform.position = auxVector;
            //Debug.Log("Blue print Hit " + hit.collider.gameObject.tag);


            transform.position = hit.point;
        }

        if (Input.GetKeyDown(GameVars.Values.primaryFire) && canBuild)
        {
            _player.SwitchIsCrafting();
            //secondAuxVector = new Vector3(transform.position.x, 1f, transform.position.z);
            //finalPosition = secondAuxVector;
            finalPosition = transform.position;
            finalRotation = transform.rotation;
            StartCoroutine(BuildTrap());

            /* Instantiate(particles, transform.position, transform.rotation);
            GameObject aux = Instantiate(trapAnimPrefab, transform.position, transform.rotation);
            //Destroy(aux.GetComponent<InventoryItem>());
            craftingRecipe.RemoveItems();
            craftingRecipe.RestoreBuildAmount();
            Destroy(gameObject); */
        }

        if (Input.GetKeyDown(GameVars.Values.secondaryFire))
        {
            _player.SwitchIsCrafting();
            Destroy(gameObject);
            craftingRecipe.RestoreBuildAmount();
        }

        if (Input.GetAxis("Mouse ScrollWheel") > 0)
        {
            transform.Rotate(Vector3.up * -15f, Space.Self);
        }

        if (Input.GetAxis("Mouse ScrollWheel") < 0)
        {
            transform.Rotate(Vector3.up * 15f, Space.Self);
        }
    }

    private IEnumerator BuildTrap()
    {
        var particlesInstantiated = Instantiate(particles, transform.position, transform.rotation);
        //myRenderer.enabled = false; //Probar despues de arreglar posicionamiento.

        //Renderer[] rs = GetComponentsInChildren<Renderer>();
        foreach (Renderer r in _myChildrenRenderers)
            r.enabled = false;

        //Canbuild provisional.
        canBuild = false;
        GameVars.Values.soundManager.PlaySoundAtPoint("TrapConstructionSnd", transform.position, 0.9f);
        yield return new WaitForSeconds(2f);
        GameObject aux = Instantiate(trapAnimPrefab, finalPosition, finalRotation, parent.transform);
        //Destroy(aux.GetComponent<InventoryItem>());
        craftingRecipe.RemoveItemsAndWitts();
        craftingRecipe.RestoreBuildAmount();
        Destroy(particlesInstantiated);
        Destroy(gameObject);

    }

    private void ChangeMaterial()
    {
        //Renderer[] rs = GetComponentsInChildren<Renderer>();
        foreach (Renderer r in _myChildrenRenderers)
            r.material = newMaterial;

        //myRenderer.material = newMaterial; //Probar despues de arreglar posicionamiento.
    }

    private void SetOriginalMaterial()
    {
        //Renderer[] rs = GetComponentsInChildren<Renderer>();
        foreach (Renderer r in _myChildrenRenderers)
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
