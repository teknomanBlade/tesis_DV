using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Blueprint : MonoBehaviour
{
    public delegate void OnSmokeParticlePositionDelegate(Vector3 smokeParticlePos);
    public event OnSmokeParticlePositionDelegate OnSmokeParticlePosition;
    private Player _player;
    RaycastHit hit;
    Vector3 movePoint;
    private bool canBuild;
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
    int layerMask;
    private GameObject parent;
    public float time;
    public int ClickCounter;
    void Start()
    {
        parent = GameObject.Find("MainGame");
        _player = GameObject.Find("Player").GetComponent<Player>();
        int layerMask = GameVars.Values.GetWallLayer();
        layerMask = ~layerMask;
        canBuild = true;
        ClickCounter = 0;
        //originalMaterial = GetComponent<Renderer>().material; //Probar despues de arreglar posicionamiento. 
        originalMaterial = GetComponentInChildren<Renderer>().material;
        //myRenderer = GetComponent<Renderer>(); //Probar despues de arreglar posicionamiento.
        _myChildrenRenderers = GetComponentsInChildren<Renderer>();
        OnSmokeParticlePosition += GameVars.Values.OnSmokeParticlesPosition;
    }

    void Update()
    {
        if (Physics.Raycast(GameVars.Values.GetPlayerCameraPosition(), GameVars.Values.GetPlayerCameraForward(), out hit, 100f, LayerMaskWall))
        {
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
            transform.position = hit.point;
        }

        if (Input.GetKeyDown(GameVars.Values.primaryFire) && canBuild)
        {
            ClickCounter++;

            if (ClickCounter > 1) return;

            _player.SwitchIsCrafting();
            finalPosition = transform.position;
            finalRotation = transform.rotation;
            StartCoroutine(BuildTrap());
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
    }

    private IEnumerator BuildTrap()
    {
        _canBeCancelled = false;
        if (!trapAnimPrefab.name.Equals("SlowTrap")) 
        {
            OnSmokeParticlePosition(transform.position);
            particles = GameVars.Values.SmokeParticlesPool.GetObject().gameObject;
            GameVars.Values.soundManager.PlaySoundAtPoint("TrapConstructionSnd", transform.position, 0.9f);
        } 
        else
        {
            GameVars.Values.soundManager.PlaySoundAtPoint("SFX_TarPouringLiquid", transform.position, 0.9f);
        }

        _myChildrenRenderers.ToList().ForEach(r =>
        {
            r.enabled = false;
        });

        //Canbuild provisional.
        canBuild = false;
        var anim = trapAnimPrefab.GetComponent<Animator>();
        if (anim)
        {
            var clips = anim.runtimeAnimatorController.animationClips;
            time = clips.First().length;
        }
        else
        {
            time = 2f;
        }
        yield return new WaitForSeconds(1f);
        GameObject aux = Instantiate(trapAnimPrefab, finalPosition, finalRotation, parent.transform);

        yield return new WaitForSeconds(time);
        if (_spendMaterials)
        {
            craftingRecipe.RemoveItemsAndWitts(); 
        }

        craftingRecipe.RestoreBuildAmount();
        
        if (!trapAnimPrefab.name.Equals("SlowTrap"))
        {
            GameVars.Values.SmokeParticlesPool.ReturnObject(particles.GetComponent<ParticleSystem>());
        }
        Destroy(gameObject);

    }

    private void ChangeMaterial()
    {
        _myChildrenRenderers.ToList().ForEach(r =>
        {
            r.material = newMaterial;
        });
    }

    private void SetOriginalMaterial()
    {
        _myChildrenRenderers.ToList().ForEach(r =>
        {
            r.material = originalMaterial;
        });
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

    public Blueprint SpendMaterials(bool value)
    {
        _spendMaterials = value;
        return this;
    }

    public Blueprint CanBeCancelled(bool value)
    {
        _canBeCancelled = value;
        return this;
    }
}
