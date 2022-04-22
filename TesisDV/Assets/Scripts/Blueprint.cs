using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blueprint : MonoBehaviour
{
    RaycastHit hit;
    Vector3 movePoint;
    Vector3 auxVector;
    public CraftingRecipe craftingRecipe;
    public GameObject trapPrefab;
    public GameObject customPivot;

    void Start()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        if(Physics.Raycast(ray, out hit, 10f, GameVars.Values.GetFloorLayerMask()))
        {
            customPivot.transform.position = hit.point;
        }
    }

    void Update()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        if(Physics.Raycast(ray, out hit, 50000.0f, GameVars.Values.GetFloorLayerMask()))
        {
            auxVector = new Vector3(hit.point.x, 1f, hit.point.z);
            transform.position = auxVector;
        }

        if(Input.GetKeyDown(GameVars.Values.primaryFire))
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
    }
}
