using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoolObjectStack<T>
{
    public delegate T FactoryMethod();
    public delegate void InitFinitMethod(T o);
    private Stack<T> _objects;
    private FactoryMethod _factoryMethod;
    private InitFinitMethod _activateMethod;
    private InitFinitMethod _desactivateMethod;
    private bool _isDynamic;

    public PoolObjectStack(FactoryMethod fM, InitFinitMethod activateMethod, InitFinitMethod desactivateMethod, int initialStock = 0, bool isDynamic = true)
    {
        _objects = new Stack<T>();
        _factoryMethod = fM;
        _activateMethod = activateMethod;
        _desactivateMethod = desactivateMethod;

        _isDynamic = isDynamic;

        for (int i = 0; i < initialStock; i++)
        {
            var o = _factoryMethod();
            _desactivateMethod(o);
            _objects.Push(o);
        }
    }

    public T GetObject()
    {
        if (_objects.Count > 0)
        {
            var o = _objects.Pop();
            _activateMethod(o);
            return o;
        }
        else if (_isDynamic)
        {
            var ob = _factoryMethod();
            _activateMethod(ob);
            return ob;
        }

        return default(T);
    }

    public void ReturnObject(T o)
    {
        _desactivateMethod(o);
        _objects.Push(o);
    }
}
