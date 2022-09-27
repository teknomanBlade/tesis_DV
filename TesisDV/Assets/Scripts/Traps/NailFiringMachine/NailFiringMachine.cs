using System.Runtime.Versioning;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class NailFiringMachine : Trap, IMovable, IInteractable
{
    [SerializeField] private float _currentLife;
    [SerializeField] private GameObject blueprintPrefab;
    [SerializeField] private List<GameObject> _myItems;
    public PoolObject<Nail> NailsPool { get; set; }
    public Nail Nail { get; private set; }
    public int InitialStock { get; private set; }
    public float interval;
    public GameObject spawnPoint;
    public int shots = 30;
    public int shotsLeft;
    private Coroutine ShootCoroutine; 
    void Awake()
    {
        active = true; // Ahora las trampas empiezan encendidas.
        _animator = GetComponent<Animator>();
        shotsLeft = shots;
        InitialStock = 30;
        Nail = Resources.Load<Nail>("Nail");
        NailsPool = new PoolObject<Nail>(NailFactory, ActivateNail, DeactivateNail, InitialStock, true);
        myCannon = transform.GetChild(1);
        StartTrap();
    }

    void Update()
    {
        if (active)
        {
            FieldOfView();
        }
    }

    private void StartTrap()
    {
        active = true;
        _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        if (ShootCoroutine != null) StopCoroutine(ShootCoroutine);
        ShootCoroutine = StartCoroutine("ActiveCoroutine");
    }

    public void Interact()
    {
        if (!active)
        {
            Debug.Log("Active la torreta");

            active = true;
            if (ShootCoroutine != null) StopCoroutine(ShootCoroutine);
            ShootCoroutine = StartCoroutine("ActiveCoroutine");
        }
    }
    IEnumerator ActiveCoroutine()
    {
        if (active)
        {
            FireNail();
            yield return new WaitForSeconds(interval);
            if (shotsLeft != 0) StartCoroutine("ActiveCoroutine");
            else active = false;
        }
        else
        {
            yield return new WaitForSeconds(0.01f);
        }

    }

    public void TakeDamage(float dmgAmount)
    {
        _currentLife -= dmgAmount;
        //GameVars.Values.soundManager.PlaySoundOnce(_as, "TurretHitDamage", 0.25f, false);
        //HitTurret.gameObject.SetActive(true);
        //HitTurret.Play();
        if (_currentLife <= 0)
        {
            //Hacer animacion de destrucción, instanciar sus objetos de construcción y destruirse.
            DestroyThisTrap();
        }
    }    

    private void FireNail()
    {
        if(_canShoot)
        {
            NailsPool.GetObject().SetInitialPos(spawnPoint.transform.position).SetOwner(this);
        }
        
    }

    private void DeactivateNail(Nail o)
    {
        o.gameObject.SetActive(false);
        o.transform.localPosition = new Vector3(0f, 0f, 0f);
    }

    private void ActivateNail(Nail o)
    {
        o.gameObject.SetActive(true);
    }

    private Nail NailFactory()
    {
        return Instantiate(Nail);
    }

    public void BecomeMovable()
    {
        GameVars.Values.currentShotsTrap2 = shotsLeft;
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        Destroy(gameObject);
    }

    public override void Inactive()
    {
        active = false;
    }

    public void DestroyThisTrap()
    {
        Vector3 aux = new Vector3(0, 0.4f, 0);
        for (int i = 0; i < _myItems.Count; i++)
        {
            Vector3 itemPos = new Vector3(UnityEngine.Random.Range(0.1f, 2.3f), 0, UnityEngine.Random.Range(0.1f, 2.3f));
            Instantiate(_myItems[i], transform.position + aux + itemPos, Quaternion.Euler(-90f, 0f, 0f));
        }
        Destroy(gameObject);
    }

    void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, viewRadius);
        Vector3 lineA = GetVectorFromAngle(viewAngle / 2 + transform.eulerAngles.y);
        Vector3 lineB = GetVectorFromAngle(-viewAngle / 2 + transform.eulerAngles.y);

        Gizmos.DrawLine(transform.position, transform.position + lineA * viewRadius);
        Gizmos.DrawLine(transform.position, transform.position + lineB * viewRadius);
    }

    Vector3 GetVectorFromAngle(float angle)
    {
        return new Vector3(Mathf.Sin(angle * Mathf.Deg2Rad), 0, Mathf.Cos(angle * Mathf.Deg2Rad));
    }
}
