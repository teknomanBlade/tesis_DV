using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class StaticBlueprint : MonoBehaviour
{
    public delegate void OnSmokeParticlePositionDelegate(Vector3 smokeParticlePos);
    public event OnSmokeParticlePositionDelegate OnSmokeParticlePosition;
    private Player _player;
    RaycastHit hit;
    [SerializeField]
    private TrapBase _trapBase;
    [SerializeField]
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
    public int ClickCounter;
    int layerMask;
    private GameObject _parent;
    public float time;
    void Start()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        _trapBases = FindObjectsOfType<TrapBase>().ToList();
        int layerMask = GameVars.Values.GetWallLayer();
        layerMask = ~layerMask;
        canBuild = false;
        originalMaterial = GetComponentInChildren<Renderer>().material;
        _myChildrenRenderers = GetComponentsInChildren<Renderer>();
        OnSmokeParticlePosition += GameVars.Values.OnSmokeParticlesPosition;
    }

    void Update()
    {
        if (Input.GetKeyDown(GameVars.Values.primaryFire) && canBuild)
        {
            ClickCounter++;

            if (ClickCounter > 1) return;

            _player.SwitchIsCrafting();
            finalPosition = transform.position;
            finalRotation = transform.rotation;
            _trapBase?.BuildOnBase();
            _parent = _trapBase?.transform.gameObject;
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

        if (Physics.Raycast(GameVars.Values.GetPlayerCameraPosition(), GameVars.Values.GetPlayerCameraForward(), out hit, 100f, TrapBaseMaskWall))
        {
            if (hit.transform.name.Contains("TeslaCoilGenerator"))
            {
                var trapBase = hit.transform.GetComponentInChildren<TrapBase>();
                if (trapBase._isAvailable) 
                {
                    _trapBase = trapBase;
                    transform.position = _trapBase.transform.position;
                }
                SetOriginalMaterial();
            }
            else 
            {
                _trapBase = hit.transform.GetComponent<TrapBase>();
                transform.position = hit.transform.position;
                SetOriginalMaterial();
            }
            canBuild = true;
            _trapBases.ForEach(x => 
            { 
                if(x.gameObject.name.Equals(_trapBase?.gameObject.name))
                    x.SetNormalIntensity(); 
            });
            
            return;
        }
        else
        {
            canBuild = false;
            _trapBases.ForEach(x =>
            {
                if (x.gameObject.name.Equals(_trapBase?.gameObject.name))
                    x.SetHighIntensity();
            });
            ChangeMaterial();
        }

        if (Physics.Raycast(GameVars.Values.GetPlayerCameraPosition(), GameVars.Values.GetPlayerCameraForward(), out hit, 100f, LayerMaskWall) )
        {
            canBuild = false;
            transform.position = hit.point;
            ChangeMaterial();
        }
    }

    private IEnumerator BuildTrap()
    {
        _canBeCancelled = false;
        OnSmokeParticlePosition(transform.position);
        particles = GameVars.Values.SmokeParticlesPool.GetObject().gameObject;
        _myChildrenRenderers.ToList().ForEach(r =>
        {
            r.enabled = false;
        });

        //Canbuild provisional.
        canBuild = false;
        GameVars.Values.soundManager.PlaySoundAtPoint("TrapConstructionSnd", transform.position, 0.9f);
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

        GameObject aux = Instantiate(trapAnimPrefab, finalPosition, finalRotation, _parent.transform);

        yield return new WaitForSeconds(time);
        if (_spendMaterials)
        {
            craftingRecipe.RemoveItemsAndWitts();
        }
        
        craftingRecipe.RestoreBuildAmount();
        GameVars.Values.SmokeParticlesPool.ReturnObject(particles.GetComponent<ParticleSystem>());
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
