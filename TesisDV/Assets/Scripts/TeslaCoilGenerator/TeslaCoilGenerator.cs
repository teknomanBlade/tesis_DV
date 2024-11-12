using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class TeslaCoilGenerator : Trap, IMovable, IInteractable
{
    private float _trapBase1Angle;
    private float _trapBase2Angle;
    private float _distance;
    public AudioSource _as;
    public List<Vector3> posTrapBases = new List<Vector3>();
    public TrapBase trapBasePrefab;
    public PoolObjectStack<TrapBase> TrapBasePool { get; set; }
    public int InitialStock { get; private set; }
    public int TrapBaseCount { get; private set; }

    public bool IsMoving;
    public GameObject blueprintPrefab;

    private void Awake()
    {
        InitialStock = 5;
        IsMoving = false;
        _trapBase1Angle = 25f;
        _trapBase2Angle = -20f;
        _distance = 3.8f;
        TrapBasePool = new PoolObjectStack<TrapBase>(TrapBaseFactory, ActivateTrapBase, DeactivateTrapBase, InitialStock, true);
        SetUIIndicator("UI_TeslaCoilGenerator_Indicator");
    }

    // Start is called before the first frame update
    void Start()
    {
        _as = GetComponent<AudioSource>();
        GameVars.Values.soundManager.PlaySound(_as, "SFX_TeslaCoilGenerator", 0.15f, true, 1f);
        SetTrapBases();
    }
   
    private void DeactivateTrapBase(TrapBase tb)
    {
        tb.gameObject.SetActive(false);
        tb.gameObject.transform.parent = transform;
        if (!tb.gameObject.name.Contains("_"))
        {
            TrapBaseCount++;
            tb.gameObject.name = tb.gameObject.name.Replace("(Clone)", "");
            tb.gameObject.name += "_" + TrapBaseCount;
        }
        tb.transform.localPosition = Vector3.zero;
        tb.transform.position = Vector3.zero;
    }

    private void ActivateTrapBase(TrapBase tb)
    {
        tb.gameObject.SetActive(true);
    }

    private TrapBase TrapBaseFactory()
    {
        return Instantiate(trapBasePrefab);
    }
    private void SetTrapBases() 
    {
        Vector3 distantPositionTrapBase1 = transform.localPosition +
             Quaternion.Euler(0, 0, _trapBase1Angle) * Vector3.up * _distance;
        distantPositionTrapBase1.x = transform.position.x - 1.45f;
        distantPositionTrapBase1.y = transform.localPosition.y + 0.05f;

        Vector3 distantPositionTrapBase2 = transform.localPosition +
         Quaternion.Euler(0, 0, _trapBase2Angle) * Vector3.up * _distance;
        distantPositionTrapBase2.x = transform.localPosition.x + 1.55f;
        distantPositionTrapBase2.y = transform.localPosition.y + 0.05f;
        distantPositionTrapBase2.z = transform.localPosition.z + 0.05f;

        posTrapBases.Add(distantPositionTrapBase1);
        posTrapBases.Add(distantPositionTrapBase2);

        for (int i = 0; i < posTrapBases.Count; i++)
        {
            TrapBasePool.GetObject().SetPos(posTrapBases[i]);
        }
    }
    // Update is called once per frame
    void Update()
    {
        
    }
    public TeslaCoilGenerator SetMovingToFalse(bool isMoving)
    {
        IsMoving = isMoving;
        return this;
    }
    public TeslaCoilGenerator SetInitPos(Vector3 pos)
    {
        this.transform.position = pos;
        return this;
    }
    public TeslaCoilGenerator SetInitRot(Quaternion rot)
    {
        this.transform.rotation = rot;
        return this;
    }
    public TeslaCoilGenerator SetParent(Transform parent)
    {
        this.transform.parent = parent;
        return this;
    }
    public void BecomeMovable()
    {
        IsMoving = true; 
        GameVars.Values.TeslaCoilGeneratorPool.ReturnObject(this);
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        aux.GetComponent<Blueprint>().SpendMaterials(false).CanBeCancelled(false);

        transform.parent = null;
    }

    public void Interact()
    {
        Debug.Log("HOLA SOY EL GENERADOR DE TESLA!");
    }
}
