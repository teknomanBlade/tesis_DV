using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NailFiringMachine : Item, IMovable
{
    public PoolObject<Nail> NailsPool { get; set; }
    public Nail Nail { get; private set; }
    public int InitialStock { get; private set; }
    public float interval;
    public GameObject spawnPoint;
    public int shots = 30;
    public int shotsLeft;
    public bool active = false;
    private Coroutine ShootCoroutine;
    // Start is called before the first frame update
    void Awake()
    {
        InitialStock = 30;
        Nail = Resources.Load<Nail>("Nail");
        NailsPool = new PoolObject<Nail>(NailFactory, ActivateNail, DeactivateNail, InitialStock, true);
    }

    public override void Interact()
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

    private void FireNail()
    {
        NailsPool.GetObject().SetInitialPos(spawnPoint.transform.position).SetOwner(this);
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

    // Update is called once per frame
    void Update()
    {
        
    }

    public void BecomeMovable()
    {
        throw new NotImplementedException();
    }
}
