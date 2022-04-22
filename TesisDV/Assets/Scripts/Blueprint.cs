using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blueprint : MonoBehaviour
{
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
        

        //Canbuild provisional.
        if(Physics.Raycast(ray, out hit, 10f, GameVars.Values.GetFloorLayerMask()) && canBuild)
        {
            auxVector = new Vector3(hit.point.x, 1f, hit.point.z);
            transform.position = auxVector;
        }

        if(Input.GetKeyDown(GameVars.Values.primaryFire) && canBuild)
        {
            secondAuxVector = new Vector3(transform.position.x, 0.25f, transform.position.z);
            finalPosition = secondAuxVector;
            finalRotation = transform.rotation;
            StartCoroutine(BuildTrap());

            /* Instantiate(particles, transform.position, transform.rotation);
            GameObject aux = Instantiate(trapAnimPrefab, transform.position, transform.rotation);
            //Destroy(aux.GetComponent<InventoryItem>());
            craftingRecipe.RemoveItems();
            craftingRecipe.RestoreBuildAmount();
            Destroy(gameObject); */
        }

        if(Input.GetKeyDown(KeyCode.Alpha2))
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
        myRenderer.enabled = false;
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
