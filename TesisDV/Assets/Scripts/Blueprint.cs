using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blueprint : MonoBehaviour
{
    RaycastHit hit;
    Vector3 movePoint;
    private bool canBuild;
    Vector3 auxVector;
    public CraftingRecipe craftingRecipe;
    public GameObject trapPrefab;
    public GameObject customPivot;
    [SerializeField]
    private Material newMaterial;
    private Material originalMaterial;
    private Renderer myRenderer;

    void Start()
    {
        canBuild = true;
        originalMaterial = GetComponent<Renderer>().material;
        myRenderer = GetComponent<Renderer>();
    }

    void Update()
    {
        Debug.Log(originalMaterial);
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        
        if(Physics.Raycast(ray, out hit, 50000.0f, GameVars.Values.GetFloorLayerMask()))
        {
            auxVector = new Vector3(hit.point.x, 1f, hit.point.z);
            transform.position = auxVector;
        }

        if(Input.GetKeyDown(GameVars.Values.primaryFire) && canBuild)
        {
            GameObject aux = Instantiate(trapPrefab, transform.position, transform.rotation);
            Destroy(aux.GetComponent<InventoryItem>());
            craftingRecipe.RemoveItems();
            craftingRecipe.RestoreBuildAmount();
            Destroy(gameObject);
        }

        if(Input.GetKeyDown(KeyCode.Alpha2))
        {
            Destroy(gameObject);
            craftingRecipe.RestoreBuildAmount();
        }

        if (Input.GetAxis("Mouse ScrollWheel") > 0) 
        {
        transform.Rotate(Vector3.forward * -7f, Space.Self);
        }

        if (Input.GetAxis("Mouse ScrollWheel") < 0) 
        {
        transform.Rotate(Vector3.forward * 7f, Space.Self);
        }
    }

    private void ChangeMaterial()
    {
        myRenderer.material = newMaterial;
    }

    private void SetOriginalMaterial()
    {
        myRenderer.material = originalMaterial;
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
