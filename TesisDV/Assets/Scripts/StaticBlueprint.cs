using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class StaticBlueprint : MonoBehaviour
{
    private Player _player;
    RaycastHit hit;
    private TrapBase _trapBase;
    private List<TrapBase> _trapBases;
    Vector3 movePoint;
    [SerializeField] private bool canBuild;
    private bool _canBeCancelled;
    private bool _spendMaterials;
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
    public LayerMask TrapBaseMaskWall;
    int layerMask;
    private GameObject _parent;  

    void Start()
    {
        //_parent = GameObject.Find("MainGame");
        _player = GameObject.Find("Player").GetComponent<Player>();
        _trapBases = FindObjectsOfType<TrapBase>().ToList();
        int layerMask = GameVars.Values.GetWallLayer();
        layerMask = ~layerMask;
        canBuild = false;
        //originalMaterial = GetComponent<Renderer>().material; //Probar despues de arreglar posicionamiento. 
        originalMaterial = GetComponentInChildren<Renderer>().material;
        //myRenderer = GetComponent<Renderer>(); //Probar despues de arreglar posicionamiento.
        _myChildrenRenderers = GetComponentsInChildren<Renderer>();

    }

    void Update()
    {
        if (Input.GetKeyDown(GameVars.Values.primaryFire) && canBuild)
        {
            _player.SwitchIsCrafting();
            //secondAuxVector = new Vector3(transform.position.x, 1f, transform.position.z);
            //finalPosition = secondAuxVector;
            finalPosition = transform.position;
            finalRotation = transform.rotation;
            _trapBase.BuildOnBase();
            _parent = _trapBase.transform.gameObject;
            StartCoroutine(BuildTrap());

            /* Instantiate(particles, transform.position, transform.rotation);
            GameObject aux = Instantiate(trapAnimPrefab, transform.position, transform.rotation);
            //Destroy(aux.GetComponent<InventoryItem>());
            craftingRecipe.RemoveItems();
            craftingRecipe.RestoreBuildAmount();
            Destroy(gameObject); */
        }

        if (Input.GetKeyDown(GameVars.Values.secondaryFire) && _canBeCancelled)
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

        if (Physics.Raycast(GameVars.Values.GetPlayerCameraPosition(), GameVars.Values.GetPlayerCameraForward(), out hit, 100f, TrapBaseMaskWall))
        {
            _trapBase = hit.transform.GetComponent<TrapBase>();
            //if(_trapBase._isAvailable)
            //{
                canBuild = true;
                _trapBases.ForEach(x => x.SetNormalIntensity());
                //_trapBase?.SetNormalIntensity();
                transform.position = hit.transform.position;
                SetOriginalMaterial();
                return;
            //}
        }
        else
        {
            canBuild = false;
            _trapBases.ForEach(x => x.SetHighIntensity());
            //_trapBase?.SetHighIntensity();
            ChangeMaterial();
        }

        if (Physics.Raycast(GameVars.Values.GetPlayerCameraPosition(), GameVars.Values.GetPlayerCameraForward(), out hit, 100f, LayerMaskWall) )
        {
            //auxVector = new Vector3(hit.point.x, 1f, hit.point.z);
            //transform.position = auxVector;
            //Debug.Log("Blue print Hit " + hit.collider.gameObject.tag);

            canBuild = false;
            transform.position = hit.point;
            ChangeMaterial();
        }
    }

    private IEnumerator BuildTrap()
    {
        _canBeCancelled = false;
        var particlesInstantiated = Instantiate(particles, transform.position, transform.rotation);
        //myRenderer.enabled = false; //Probar despues de arreglar posicionamiento.

        //Renderer[] rs = GetComponentsInChildren<Renderer>();
        foreach (Renderer r in _myChildrenRenderers)
            r.enabled = false;

        //Canbuild provisional.
        canBuild = false;
        GameVars.Values.soundManager.PlaySoundAtPoint("TrapConstructionSnd", transform.position, 0.9f);

        yield return new WaitForSeconds(2f);

        GameObject aux = Instantiate(trapAnimPrefab, finalPosition, finalRotation, _parent.transform);
        //Destroy(aux.GetComponent<InventoryItem>());

        if(_spendMaterials)
        {
            craftingRecipe.RemoveItemsAndWitts();
        }
        
        craftingRecipe.RestoreBuildAmount();
        //Destroy(particlesInstantiated);
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

    public StaticBlueprint SpendMaterials(bool value)
    {
        _spendMaterials = value;
        return this;
    }

    public StaticBlueprint CanBeCancelled(bool value)
    {
        _canBeCancelled = value;
        return this;
    }
}
