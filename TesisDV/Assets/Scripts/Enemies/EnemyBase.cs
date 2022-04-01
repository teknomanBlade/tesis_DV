using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public abstract class EnemyBase : MonoBehaviour
{
    protected LevelManager _lvm;
    protected Rigidbody _rb;
    public Vector3 nextPos;
    public int nextIndex = 1;
    public float distanceLimit = 5f;
    public bool end = false;
    public float speed = 2f;

    protected virtual void Awake()
    {
        _lvm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _rb = GetComponent<Rigidbody>();
        GetNextPos();
    }

    protected virtual void Update()
    {
        if (!_lvm.playing) Die();

        //Debug.Log(Vector3.Distance(transform.position, nextPos));
        if (!end)
        {
            if (Arrived()) GetNextPos();
            else Move();
        }
    }

    protected virtual void GetNextPos()
    {
        nextPos = _lvm.GetNextPos(nextIndex);
        if (nextPos.Equals(default(Vector3))) end = true;
        else
        {
            Vector3 lookPos = new Vector3(nextPos.x, transform.position.y, nextPos.z);
            transform.LookAt(lookPos);
            nextIndex++;
        }
    }

    protected virtual void Move()
    {
        transform.position += transform.forward * speed * Time.deltaTime;
    }

    protected virtual bool Arrived()
    {
        if (Vector3.Distance(transform.position, nextPos) < distanceLimit)
        {
            //Debug.Log("Arrived");
            return true;
        }
        else return false;
    }

    public virtual void Die()
    {
        _lvm.spawnedEnemies.Remove(this);
        Destroy(this.gameObject);
    }
}
